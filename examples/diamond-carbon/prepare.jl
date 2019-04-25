# Prepare: load data and configure settings.
# Use a script file instead of a config text file to prepare the run, since it could make 

import Seer
import Seer: NetworkInput, NetworkOutput, TrainingAlgorithms

function data_training()
    data_files = [joinpath(@__DIR__, "data", string(i)) for i in 1:250]
end

function data_predict()
    data_files = [joinpath(@__DIR__, "data", string(i)) for i in 251:300]
end

function configure(datalist::Vector{<:AbstractString}, continuing::Bool = false)
    Seer.configure(
        # Network settings
        input = NetworkInput.Structure, # Use structure configuration as input.
        output = NetworkOutput.Energy,  # Use total energy as output.
        hidden_layers = [20],                # 1 hidden layer of 20 nodes.
        transfer = tanh,                     # Use tanh as transfering functions in the nodes.
        # Geometry mapping function specifications
        cutoff_radius = 4.0, # Set cutoff radius for inter-atomic interactions in a potential.
        num_radial = 5,      # 5 radial functions.
        num_angular = 4,     # 4 angular functions.
        # Training details
        algorithm = TrainingAlgorithms.ResillientBackpropagation, # Set the algorithm used in training.
        num_iteration = 300,                                           # Run 300 iterations for training.
        threshold = 0.0,                                               # Threshold based on gradient for stopping.
        period_logging = 10,                                           # Log every 10 steps.
        checkpoint_filename = "potential",                             # Filename prefix for checkpoints.
        period_checkpoint = 100,                                       # Save checkpoints every 100 steps.
        # Others
        random_seed = 200701281, # Random seed for reproducibility.
    )
end
