module _structure

import ...Bases: Vector3, Matrix3, Nullable
import ...NetworkInput: NetworkInputType

struct AtomType
    element::Int
    type::Int
end

struct G2Function
    cutoff_radius::Float64
    fc_type::Int
    η::Float64
    Rs::Float64
end

struct G4Function
    cutoff_radius::Float64
    fc_type::Int
    η::Float64
    ξ::Float64
    λ::Float64
end

mutable struct Helper
    norms::Vector3
    f_to_a::Matrix3
    a_to_f::Matrix3
end

struct Structure <: NetworkInputType
    atom_types::Vector{_structure.AtomType}  # Element number and atom type.

    basis::Matrix3
    rec_basis::Matrix3
    positions::Vector{Vector3}

    # Mapping functions
    g2::Vector{_structure.G2Function}
    g4::Vector{_structure.G4Function}

    helper::Ref{Nullable{Helper}}
    Structure(at, b, r, p) = new(
        at, b, r, p,
        [], [], nothing
    )
end

function Helper(s::Structure, rcut::Float64)
    # Conversion
    norms = Vector3([
        LinearAlgebra.norm(s.basis[:, i])
        for i in 1:3
    ])
    f_to_a = copy(s.basis)
    a_to_f = inv(f_to_a)
    # Neighbours

    Helper(norms, f_to_a, a_to_f)
end

# Initialize the G's
function init_gs!(s::Structure, rcut::Float64, num_radial::Int, num_angular::Int)
    # Currently only use radial and angular ones.
    step_size = rcut / (num_radial - 1)
    rs = 0.0
    while rs ≤ rcut
        push!(s.mappings.g2, _structure.G2Function(
            rcut, 0,
            11.5129254649702 / (4 * step_size * step_size),
            rs
        ))
        rs += step_size
    end
    step_size = 2 * 15.0 / (num_angular - 2);
    ξ = 1.0
    while ξ ≤ 16.001
        g = _structure.G4Function(
            rcut, 0,
            4.60517018598809 / (rcut * rcut), ξ, 1
        )
        push!(s.mappings.g4, g)
        g = _structure.G4Function(
            rcut, 0,
            g.η, ξ, -1
        )
        push!(s.mappings.g4, g)
        ξ += step_size
    end
end

function initialize!(s::Structure, rcut::Float64, num_radial::Int, num_angular::Int)
    init_gs!(s, rcut, num_radial, num_angular)
    s.helper[] = Helper(s, rcut)
    # TODO: initialize
    s
end

end

import ._structure: Structure
