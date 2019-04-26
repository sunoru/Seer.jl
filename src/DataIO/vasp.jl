import EzXML

import ..Bases: Vector3, Matrix3
import ..DataFile
import ..NetworkInput
import ..NetworkOutput

function load_data(::Type{NetworkInput.Structure}, filename::AbstractString, ::Type{DataFile.VASP})
    if !endswith(filename, "xml")
        filename = joinpath(filename, "vasprun.xml")
    end
    doc = EzXML.readxml(filename)
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
    atom_types = String[
        strip(nodes[element_i].content) * strip(nodes[atomtype_i].content)
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
    energy = NetworkOutput.Energy()
end
