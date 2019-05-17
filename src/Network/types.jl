import Flux

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
    data::Data{I, O}
    config::Config
end
