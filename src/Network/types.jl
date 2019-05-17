import Flux
import Flux: Tracker

import ..Configurations: Config
import ..DataIO: Data
import ..NetworkInput, ..NetworkOutput


mutable struct NeuralNetwork
    chain::Flux.Chain
    means::Vector{Float64}
    variances::Vector{Float64}
end

mutable struct NetworkSetup{I <: NetworkInput.NetworkInputType, O <: NetworkOutput.NetworkOutputType}
    networks::Dict{Int, NeuralNetwork}  # Element Number => NN
    params::Tracker.Params
    data::Data{I, O}
    config::Config
end
