module Main

import ..DataIO: Data, DataFile
import ..Configurations: Config

function train(filenames::Vector{<:AbstractString}, config::Config; datatype::Type{<:DataFile.DataFileType} = DataFile.VASP)
end

function validate(filenames::Vector{<:AbstractString}, config::Config; datatype::Type{<:DataFile.DataFileType} = DataFile.VASP)
end

end
