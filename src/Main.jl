module Main

import ..DataFile
import ..DataIO: Data, load_data
import ..Configurations: Config

import ..Network

function train(filenames::Vector{<:AbstractString}, config::Config; datatype::Type{<:DataFile.DataFileType} = DataFile.VASP)
    data = load_data(datatype, filenames, config)
    Network.initialize(data, config)
end

function validate(filenames::Vector{<:AbstractString}, config::Config; datatype::Type{<:DataFile.DataFileType} = DataFile.VASP)
    data = load_data(datatype, filenames, config)
end

end
