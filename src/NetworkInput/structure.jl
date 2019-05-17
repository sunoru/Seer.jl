module _structure

using LinearAlgebra

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

const G2 = G2Function[]
const G4 = G4Function[]
const G4Prefactor = Dict{Float64, Float64}()

struct Helper
    G::Matrix{Float64}
    sums::Dict{Int, Vector{Float64}}
    counts::Dict{Int, Int}
end

struct Structure <: NetworkInputType
    atom_types::Vector{AtomType}  # Element number and atom type.

    basis::Matrix3
    rec_basis::Matrix3
    positions::Vector{Vector3}

    helper::Ref{Nullable{Helper}}

    Structure(at, b, r, p) = new(
        at, b, r, p,
        nothing
    )
end

@inline function fc(frac, fc_switch)
    if frac >= 1.0
         0.0
    elseif fc_switch !== 0
        tanh(1 - frac)^3
    else
        x = π * frac
        if x < π / 3
            (0.043539571484819 * x - 0.273567195834312) * x * x + 1.0
        elseif x < 2π / 3
            x -= π / 3
            ((0.087079142969639 * x - 0.136783597917156) * x - 0.429718346348117) * x + 0.75
        else
            x -= 2π / 3
            ((0.043539571484819 * x + 0.136783597917156) * x - 0.429718346348117) * x + 0.25
        end
    end
end

@inline function calc_g2(g2::G2Function, r::Float64)
    exp(-g2.η * (r - g2.Rs)^2) * fc(r / g2.cutoff_radius, g2.fc_type)
end

@inline function calc_g4(g4::G4Function, r::Float64, ru::Float64, rjk::Float64, cosθ::Float64)
    prefactor = G4Prefactor[g4.ξ]
    term = 1.0 + g4.λ * cosθ
    term ≤ 0 && return 0.0
    angular = term ^ g4.ξ
    exp1 = exp(-g4.η * r * r)
    exp2 = exp(-g4.η * ru * ru)
    fc1 = fc(r / g4.cutoff_radius, g4.fc_type)
    fc2 = fc(ru / g4.cutoff_radius, g4.fc_type)
    prefactor * angular * exp1 * exp2 * fc1 * fc2
end

function calc_g!(
    G::Matrix{Float64}, i::Int, s::Structure,
    ng::Int, ng2::Int, ng4::Int,
    f_to_a::Matrix3,
    translations::Vector{Vector3},
    neighbor_list::Vector{Vector{NTuple{2, Int}}},
    element_indices::Dict{Int, Int}
)
    pos = s.positions[i]
    n_types = length(element_indices)
    for (neighbor, t) in neighbor_list[i]
        pos_neighbor = s.positions[neighbor] + translations[t]
        diff = f_to_a * (pos_neighbor - pos)
        distance = norm(diff)
        distance < 0.01 && continue
        element_i = element_indices[s.atom_types[neighbor].element]
        for j in 1:ng2
            g2i = (element_i - 1) * ng2 + j
            G[g2i, i] = calc_g2(G2[j], distance)
        end
        for (neighbor2, t2) in neighbor_list[i]
            pos_neighbor2 = s.positions[neighbor2] + translations[t2]
            diff2 = f_to_a * (pos_neighbor2 - pos)
            diff3 = f_to_a * (pos_neighbor2 - pos_neighbor)
            distance2 = norm(diff2)
            distance3 = norm(diff3)
            (distance2 < 0.01 || distance3 < 0.01) && continue
            cosθ = diff ⋅ diff2 / distance / distance2
            element_i2 = element_indices[s.atom_types[neighbor2].element]
            i1, i2 = min(element_i, element_i2), max(element_i, element_i2)
            for j in 1:ng4
                g4i = ng2 * n_types + ((n_types + n_types - i1 + 1) * (i1 - 1) ÷ 2 + i2 - 1) * ng4 + j
                G[g4i, i] = calc_g4(G4[j], distance, distance2, distance3, cosθ)
            end
        end
    end
end

function init_helper(s::Structure, rcut::Float64, all_atom_types::Vector{Int})
    # Conversion
    norms = Vector3([
        norm(s.basis[:, i])
        for i in 1:3
    ])
    f_to_a = copy(s.basis)
    a_to_f = inv(f_to_a)

    ng2 = length(G2)
    ng4 = length(G4)
    n_atom_type = length(all_atom_types)
    ng_types = ng2 + ng4
    ng = n_atom_type * ng2 + n_atom_type * (n_atom_type + 1) ÷ 2 * ng4

    # Neighbors
    # not needed
    lattice = Vector3(ceil.(1.1 * rcut ./ norms))
    translations = [
        Vector3((ix, iy, iz))
        for ix in -lattice[1]:lattice[1]
        for iy in -lattice[2]:lattice[2]
        for iz in -lattice[3]:lattice[3]
    ]
    # i => [(j, t)]
    neighbor_list = Vector{NTuple{2, Int}}[]
    n = length(s.positions)
    n_translations = length(translations)
    for i in 1:n
        push!(neighbor_list, NTuple{2, Int}[])
        x = s.positions[i]
        for j in 1:n
            for t in 1:n_translations
                y = s.positions[j] + translations[t]
                diff = f_to_a * (y - x)
                distance = norm(diff)
                if distance > 0.01 && distance ≤ rcut
                    push!(neighbor_list[i], (j, t))
                end
            end
        end
    end

    sums = Dict{Int, Vector{Float64}}()
    counts = Dict{Int, Int}()
    element_indices = Dict{Int, Int}()
    for i in 1:n_atom_type
        element = all_atom_types[i]
        element_indices[element] = i
        sums[element] = zeros(ng)
        counts[element] = 0
    end
    G = zeros(ng, n)
    for i in 1:n
        calc_g!(
            G, i, s, ng, ng2, ng4,
            f_to_a, translations,
            neighbor_list, element_indices
        )
        element = s.atom_types[i].element
        sums[element] += G[:, i]
        counts[element] += 1
    end

    Helper(
        G,
        sums, counts
    )
end

function initialize!(
    s::Structure, rcut::Float64, num_radial::Int, num_angular::Int,
    all_atom_types::Vector{Int}
)
    # Initialize the G's
    if length(G2) + length(G4) == 0
        # Currently only use radial and angular ones.
        step_size = rcut / (num_radial - 1)
        rs = 0.0
        while rs ≤ rcut
            push!(G2, G2Function(
                rcut, 0,
                11.5129254649702 / (4 * step_size * step_size),
                rs
            ))
            rs += step_size
        end
        step_size = 2 * 15.0 / (num_angular - 2);
        ξ = 1.0
        while ξ ≤ 16.001
            g = G4Function(
                rcut, 0,
                4.60517018598809 / (rcut * rcut), ξ, 1
            )
            push!(G4, g)
            g = G4Function(
                rcut, 0,
                g.η, ξ, -1
            )
            push!(G4, g)
            G4Prefactor[ξ] = 2 ^ (1 - ξ)
            ξ += step_size
        end
    end

    s.helper[] = init_helper(s, rcut, all_atom_types)

    s
end

Base.sum(s::Structure, element::Int) = s.helper[].sums[element]

function variance(s::Structure, element::Int, means::Vector{Float64})
    G = s.helper[].G
    n = length(s.atom_types)
    var = zeros(size(means))
    for i in 1:n
        s.atom_types[i].element !== element && continue
        var += (G[:, i] - means) .^ 2
    end
    var
end

Base.count(s::Structure, element::Int) = s.helper[].counts[element]

end

import ._structure: Structure
