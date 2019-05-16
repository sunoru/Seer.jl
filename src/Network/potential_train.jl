import Random: randn

import Flux

import ..Bases: Vector3, Matrix3
import ..DataIO: Data
import ..Configurations: Config
import ..NetworkInput, ..NetworkOutput
import ..NetworkInput: _structure


function initialize!(data::Data{NetworkInput.Structure, NetworkOutput.Energy}, config::Config)
    all_atom_types = Set{Int}()
    for data_pair in data.data_pairs
        types = data_pair[1][1].atom_types
        for x in types
            push!(all_atom_types, x.element)
        end
    end
    # Initialize structures
    for each in data.data_pairs
        structure = each[1]
        _structure.initialize(
            structure, config.cutoff_radius, config.num_radius, config.num_angular,
            all_atom_types
        )
    end
    # Initialize networks
    networks = Dict{Int, NeuralNetwork}()
    for element in all_atom_types
        chain = identity
        n_in = 1
        for n_out in config.hidden_layers
            layer = new_layer(n_in, n_out, config.transfer, config.rng)
            chain = chain ∘ layer
            n_in = n_out
        end
        chain = chain ∘ new_layer(n_in, 1, identity, config.rng)
        net = NeuralNetwork(chain)
        networks[element] = net
    end
    setup = NetworkSetup(networks, data, config)
    return
end

const PotentialSetup = NetworkSetup{NetworkInput.Structure, NetworkOutput.Energy}

function precondition!(setup::PotentialSetup)
    template_structure = setup.data.data_pairs[1][1]
    for (element, net) in setup.networks
        ng = template_structure.helper[].ng
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
            variances += variance(structure, element, means)
        end
        variances = sqrt.(variances / t)
        for i in 1:ng
            variances[i] = variances[i] < 1e-5 ? 1e-5 : variances[i]
        end
        net.variances = variances
    end
    setup
end

function train!(setup::PotentialSetup)
    precondition!(setup)
    setup
end
