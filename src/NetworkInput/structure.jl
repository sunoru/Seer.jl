import ..DataFile

struct Structure <: NetworkInputType
end

load_data(io::IO, data_type::Type{<:DataFile.DataFileType}, ::Type{Structure}) = load_structure(io, data_type)
