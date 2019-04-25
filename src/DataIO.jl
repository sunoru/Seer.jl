module DataIO

module DataFile

import ...Utils

Utils.@type_enum DataFileType begin
    VASP
end

end

mutable struct Data{T <: DataFile.DataFileType, DT}
    data::DT
end

function load_data(::Type{DataFile.VASP}, filename::AbstractString)
    
end

end
