import ..DataFile
import ..NetworkInput
import ..NetworkOutput

function load_data(filename::AbstractString, ::Type{DataFile.VASP}, ::Type{NetworkInput.Structure})
    structure = NetworkInput.Structure()
end

function load_data(filename::AbstractString, ::Type{DataFile.VASP}, ::Type{NetworkOutput.Energy})
    energy = NetworkOutput.Energy()
end
