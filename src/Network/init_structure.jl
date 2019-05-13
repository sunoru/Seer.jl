import LinearAlgebra

import ..Bases: Vector3, Matrix3
import ..DataIO: Data
import ..Configurations: Config
import ..NetworkInput, ..NetworkOutput
import ..NetworkInput: _structure


function initialize(data::Data{NetworkInput.Structure, NetworkOutput.Energy}, config::Config)
    # Use the first structure as template, which means it currenctly does not support different systems.
    atom_types = Set(
        atom_type.element
        for atom_type in data.data_pairs[1][1].atom_types
    )
    _structure.init_gs!(template_structure, config.cutoff_radius, config.num_radius, config.num_angular)
    for each in data.data_pairs[2:end]
        _structure.init_gs!(each[1], template_structure)
    end
    for each in data.data_pairs
        structure = each[1]
        _structure.initialize(structure, config.cutoff_radius, config.num_radius, config.num_angular)
    end
end
