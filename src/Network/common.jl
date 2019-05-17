import Printf: @printf
import Random: AbstractRNG

import BSON
import Flux
import Flux: Tracker
import PeriodicTable: elements


import ..Configurations: Config


function new_layer(n_in::Int, n_out::Int, transfer::Function, rng::AbstractRNG)
    Flux.Dense(n_in, n_out, transfer; initb = n -> randn(rng, n))
end

function save(setup::NetworkSetup)
    for (element, net) in setup.networks
        symbol = elements[element].symbol
        filename = "$(setup.config.checkpoint_output)-$(symbol).bson"
        BSON.@save filename net
    end
end

function load(atom_types, config::Config)
    networks = Dict{Int, NeuralNetwork}()
    for element in atom_types
        symbol = elements[element].symbol
        filename = "$(config.checkpoint_input)-$(symbol).bson"
        BSON.@load filename net
        networks[element] = net
    end
end

function training_callback(setup::NetworkSetup, loss::Function)
    epoch = 0
    period_logging = setup.config.period_logging
    period_checkpoint = setup.config.period_checkpoint
    batch_data = setup.data.data_pairs
    params = setup.params
    () -> begin
        epoch += 1
        if epoch % period_logging === 0
            grad_norm = (sqrt ∘ sum)(sum(Tracker.data(Tracker.grad(p)).^2) for p in params)
            @printf "%-8d%-13.6e %.6e\n" epoch setup.current_loss grad_norm
        end
        if epoch % period_checkpoint === 0
            save(setup)
        end
    end
end
