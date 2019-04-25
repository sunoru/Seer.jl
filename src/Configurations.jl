module Configurations

import RandomNumbers.Xorshifts: Xoshiro256StarStar

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
    num_iteration::Int
    threshold::Float64
    period_logging::Int
    checkpoint_filename::String
    period_checkpoint::Int

    rng::Xoshiro256StarStar
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
    num_iteration = 300,
    threshold = 0.0,
    period_logging = 10,
    checkpoint_filename = "potential",
    period_checkpoint = 100,
    random_seed = 0
)
    rng = random_seed > 0 ? Xoshiro256StarStar(random_seed) : Xoshiro256StarStar()
    Config(
        input, output, hidden_layers, transfer,
        cutoff_radius, num_radial, num_angular,
        algorithm, num_iteration, threshold, period_logging,
        checkpoint_filename, period_checkpoint,
        rng
    )
end

end
