module Configurations

import RandomNumbers.Xorshifts

import ..NetworkInput
import ..NetworkOutput
import ..TrainingAlgorithms

mutable struct Config
    input::NetworkInput.NetworkInputType
    output::NetworkOutput.NetworkOutputType
    hidden_layers::Vector{Int}
    transfer::Function
    
    cutoff_radius::Float64
    num_radial::Int
    num_angular::Int
    
    algorithm::TrainingAlgorithms.TrainingAlgorithmType
    num_iteration::Int
    threshold::Float64
    period_logging::Int
    checkpoint_filename::String
    period_checkpoint::Int

    random_seed::Int
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
    Config(
        input, output, hidden_layers, transfer,
        cutoff_radius, num_radial, num_angular,
        algorithm, num_iteration, threshold, period_logging,
        checkpoint_filename, period_checkpoint, random_seed
    )
end

end
