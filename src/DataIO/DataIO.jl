module DataIO

import ..DataFile
import ..NetworkInput
import ..NetworkOutput
import ..Configurations: Config

mutable struct Data{T <: DataFile.DataFileType, I <: NetworkInput.NetworkInputType, O <: NetworkOutput.NetworkOutputType}
    data_pairs::Vector{Tuple{I, O}}
end

function load_data(type::Type{<:DataFile.DataFileType}, filenames::Vector{<:AbstractString}, config::Config)
    data_pairs = [begin
        input = load_data(filename, type, config.input)
        output = load_data(filename, type, config.output)
        (input, output)
    end for file in filenames]
    Data{type, config.input, config.output}(data_pairs)
end

include("vasp.jl")

end
