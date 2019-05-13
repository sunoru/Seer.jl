struct NeuralNetwork
end

mutable struct NetworkSetup
    networks::Dict{Int, NeuralNetwork}  # Element Number => NN
end
