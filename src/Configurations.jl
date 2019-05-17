module Configurations

import RandomNumbers.Xorshifts: Xoshiro256StarStar

import ..Bases: Nullable
import ..NetworkInput
import ..NetworkOutput
import ..TrainingAlgorithms

mutable struct Config
    input::Type{<:NetworkInput.NetworkInputType}
    output::Type{<:NetworkOutput.NetworkOutputType}
    hidden_layers::Vector{Int}
    transfer::Function
    
    cutoff_radius::Float64
    num_radial::Int
    num_angular::Int
    
    algorithm::Type{<:TrainingAlgorithms.TrainingAlgorithmType}
    num_epoch::Int
    threshold::Float64
    period_logging::Int
    checkpoint_input::Nullable{String}
    checkpoint_output::String
    period_checkpoint::Int

    rng::Xoshiro256StarStar
    force_restart::Bool
end

function configure(;
    input = NetworkInput.Structure,
    output = NetworkOutput.Energy,
    hidden_layers = [20],
    transfer = tanh,
    cutoff_radius = 4.0,
    num_radial = 5,
    num_angular = 4,
    algorithm = TrainingAlgorithms.ResillientBackpropagation,
    num_epoch = 300,
    threshold = 0.0,
    period_logging = 10,
    checkpoint_input = nothing,
    checkpoint_output = "checkpoint",
    period_checkpoint = 100,
    random_seed = 0,
    force_restart = false,
)
    rng = random_seed > 0 ? Xoshiro256StarStar(random_seed) : Xoshiro256StarStar()
    Config(
        input, output, hidden_layers, transfer,
        cutoff_radius, num_radial, num_angular,
        algorithm, num_epoch, threshold, period_logging,
        checkpoint_input, checkpoint_output, period_checkpoint,
        rng, force_restart
    )
end

end
