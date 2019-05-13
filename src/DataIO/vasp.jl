import EzXML
import PeriodicTable: elements

import ..Bases: Vector3, Matrix3
import ..DataFile
import ..NetworkInput
import ..NetworkInput: _structure
import ..NetworkOutput

function vasp_readfile(fname)
    fname = endswith(fname, "xml") ? fname : joinpath(fname, "vasprun.xml")
    EzXML.readxml(fname)
end

function load_data(::Type{NetworkInput.Structure}, filename::AbstractString, ::Type{DataFile.VASP})
    doc = vasp_readfile(filename)
    atominfo_node = findfirst("//atominfo", doc)
    n_atoms = parse(Int, findfirst("./atoms", atominfo_node).content)
    n_types = parse(Int, findfirst("./types", atominfo_node).content)
    atoms_node = findfirst("./array[@name='atoms']", atominfo_node)
    field_nodes = findall("./field", atoms_node)
    element_i, atomtype_i = (x::Int
        for x in indexin(["element", "atomtype"],
        [node.content for node in field_nodes])
    )
    atom_list = findall("./set/rc", atoms_node)
    atom_types = [
        _structure.AtomType(elements[Symbol(strip(nodes[element_i].content))].number, parse(Int, strip(nodes[atomtype_i].content)))
        for nodes in (findall("./c", node) for node in atom_list)
    ]

    structure_node = findfirst("//structure", doc)
    node = findfirst(".//varray[@name='basis']", structure_node)
    basis = Matrix3([parse(Float64, x) for x in split(node.content)])
    node = findfirst(".//varray[@name='rec_basis']", structure_node)
    rec_basis = Matrix3([parse(Float64, x) for x in split(node.content)])
    node = findfirst(".//varray[@name='positions']", structure_node)
    vs = findall("./v", node)
    positions = [Vector3([parse(Float64, x) for x in split(v.content)]) for v in vs]
    @assert n_atoms === length(positions)

    NetworkInput.Structure(
        atom_types,
        basis, rec_basis, positions
    )
end

function load_data(::Type{NetworkOutput.Energy}, filename::AbstractString, ::Type{DataFile.VASP})
    doc = vasp_readfile(filename)
    energy_node = findfirst("//energy/i[@name='e_wo_entrp']", doc)
    energy = parse(Float64, energy_node.content)
    NetworkOutput.Energy(energy)
end
