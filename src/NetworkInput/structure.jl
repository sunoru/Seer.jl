import ..Bases: Vector3, Matrix3
import ..DataFile

struct Structure <: NetworkInputType
    atom_types::Vector{String}

    basis::Matrix3
    rec_basis::Matrix3
    positions::Vector{Vector3}
end
