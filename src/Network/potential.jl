import Random: randn

import Flux
import Flux: Tracker

import ..Bases: Vector3, Matrix3
import ..DataIO: Data
import ..Configurations: Config
import ..NetworkInput, ..NetworkOutput
import ..NetworkInput: _structure
import ..TrainingAlgorithms


function initialize!(data::Data{NetworkInput.Structure, NetworkOutput.Energy}, config::Config)
    all_atom_types = Set{Int}()
    for data_pair in data.data_pairs
        types = data_pair[1].atom_types
        for x in types
            push!(all_atom_types, x.element)
        end
    end
    if config.checkpoint_input !== nothing
        networks = load(all_atom_types, config)
        params = Flux.params((net.chain for (_, net) in networks)...)
        setup = NetworkSetup(networks, params, data, config)
        return setup
    end
    @info "Initializing for structures (mapping functions)..."
    # Initialize structures
    for each in data.data_pairs
        structure = each[1]
        _structure.initialize!(
            structure, config.cutoff_radius, config.num_radial, config.num_angular,
            collect(all_atom_types)
        )
    end
    @info "Initializing for networks..."
    # Initialize networks
    template_structure = data.data_pairs[1][1]
    ng = size(template_structure.helper[].G, 1)
    networks = Dict{Int, NeuralNetwork}()
    for element in all_atom_types
        layers = []
        n_in = Ref(ng)
        for n_out in config.hidden_layers
            layer = new_layer(n_in[], n_out, config.transfer, config.rng)
            push!(layers, layer)
            n_in[] = n_out
        end
        layer = new_layer(n_in[], 1, identity, config.rng)
        push!(layers, layer)
        chain = Flux.Chain(layers...)
        net = NeuralNetwork(chain, [], [])
        networks[element] = net
    end
    params = Flux.params((net.chain for (_, net) in networks)...)
    setup = NetworkSetup(networks, params, data, config)
end

const PotentialSetup = NetworkSetup{NetworkInput.Structure, NetworkOutput.Energy}

function precondition!(setup::PotentialSetup)
    @info "Preconditioning..."
    template_structure = setup.data.data_pairs[1][1]
    for (element, net) in setup.networks
        ng = size(template_structure.helper[].G, 1)
        means = zeros(ng)
        t = 0
        for (structure, _) in setup.data.data_pairs
            means += sum(structure, element)
            t += count(structure, element)
        end
        means /= t
        net.means = means

        variances = zeros(ng)
        for (structure, _) in setup.data.data_pairs
            variances += _structure.variance(structure, element, means)
        end
        variances = sqrt.(variances / t)
        for i in 1:ng
            variances[i] = variances[i] < 1e-5 ? 1e-5 : variances[i]
        end
        net.variances = variances
    end
    setup
end

function evaluate(
    nets::Dict{Int, NeuralNetwork},
    structure::NetworkInput.Structure
)
    output = 0.0
    for atom in structure.atom_types
        net = nets[atom.element]
        x = -net.means ./ net.variances
        output += net.chain(x)[1]
    end
    output
end

function loss_one(
    nets::Dict{Int, NeuralNetwork},
    structure::NetworkInput.Structure,
    energy::NetworkOutput.Energy
)
    output = evaluate(nets, structure)
    err = output - energy.value
end

function loss_function(setup::PotentialSetup)
    nets = setup.networks
    (data_pairs::Vector{Tuple{NetworkInput.Structure, NetworkOutput.Energy}}) -> begin
        (sqrt ∘ sum)(loss_one(nets, structure, energy)^2 for (structure, energy) in data_pairs)
    end
end

function train!(setup::PotentialSetup)
    precondition!(setup)
    loss = loss_function(setup)
    params = setup.params
    data = setup.data.data_pairs
    n_epoch = setup.config.num_epoch
    optimizer = TrainingAlgorithms.optimizer(setup.config.algorithm)
    cb1, cb2 = training_callback(setup)
    @info "Training..."
    println("Epoch     ε = √∑(E²)     |∇ε|")
    println("-----------------------------------")
    final_loss = train!(
        loss, params, n_epoch, data, optimizer;
        cb1 = cb1, cb2 = cb2
    )
    println("Final loss: $(final_loss)")
    setup
end

function validate(setup::PotentialSetup)
    @info "Validating..."
    println("System      Prediction     Target      Error")
    println("-------------------------------------------------")
    nets = setup.networks
    evaluate_function = x -> evaluate(nets, x)
    validate(evaluate_function, setup.data.data_pairs)
    setup
end
