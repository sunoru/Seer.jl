module DataIO

import ..DataFile
import ..NetworkInput
import ..NetworkOutput
import ..Configurations: Config

mutable struct Data{I <: NetworkInput.NetworkInputType, O <: NetworkOutput.NetworkOutputType}
    data_pairs::Vector{Tuple{I, O}}
end

function load_data(type::Type{<:DataFile.DataFileType}, filenames::Vector{<:AbstractString}, config::Config)
    data_pairs = [begin
        input = load_data(config.input, filename, type)
        output = load_data(config.output, filename, type)
        (input, output)
    end for filename in filenames]
    Data(data_pairs)
end

include("vasp.jl")

end
