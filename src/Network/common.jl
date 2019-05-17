import Printf: @printf
import Random: AbstractRNG

import BSON
import Flux
import Flux: Tracker
import PeriodicTable: elements


import ..Configurations: Config
import ..NetworkOutput


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
    networks
end

function training_callback(setup::NetworkSetup)
    period_logging = setup.config.period_logging
    period_checkpoint = setup.config.period_checkpoint
    (epoch, current_loss, grads) -> begin
        if epoch % period_logging === 0
            grad_norm = (sqrt ∘ sum)(sum(Tracker.data(g).^2) for (_, g) in grads)
            @printf "%-8d%-13.6e %.6e\n" epoch current_loss grad_norm
            flush(stdout)
        end
    end, epoch -> begin
        if epoch % period_checkpoint === 0
            save(setup)
        end
    end
end

function train!(
    loss::Function, params::Flux.Params, n_epoch::Int, data, optimizer;
    cb1 = (_, _, _) -> (), cb2 = _ -> ()
)
    current_loss = Ref(0.0)
    for epoch in 1:n_epoch
        try
            grads = Flux.gradient(params) do
                t = loss(data)
                current_loss[] = Tracker.data(t)
                t
            end
            cb1(epoch, current_loss[], grads)
            Tracker.update!(optimizer, params, grads)
            cb2(epoch)
        catch ex
            if ex isa Flux.Optimise.StopException
                break
            else
                rethrow(ex)
            end
        end
    end
    current_loss[]
end

function validate(
    evaluate::Function, data
)
    SSE = 0.0
    n = 0
    min_err = 2007012811.0
    max_err = 0
    for (i, (a, b)) in enumerate(data)
        prediction = Tracker.data(evaluate(a))
        target = NetworkOutput.valueof(b)
        err = prediction - target
        min_err = min(abs(err), min_err)
        max_err = max(abs(err), max_err)
        SSE += err^2
        n += 1
        @printf "%10d %12.6e  %12.6e  %12.6e\n" i prediction target err
    end
    @printf "Minimum Error =  %.6e\n" min_err
    @printf "Maximum Error =  %.6e\n" max_err
    @printf "RMS Error     =  %.6e\n" √(SSE / n)
end
