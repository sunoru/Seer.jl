module Seer

include("Utils.jl")

include("Bases.jl")

include("DataFile.jl")
export DataFile

include("NetworkInput/NetworkInput.jl")
include("NetworkOutput/NetworkOutput.jl")
export NetworkInput, NetworkOutput

include("TrainingAlgorithms.jl")
export TrainingAlgorithms

include("Configurations.jl")
Utils.@export_internal Configurations.Config, Configurations.configure

include("DataIO/DataIO.jl")
Utils.@export_internal DataIO.Data

include("Main.jl")
Utils.@export_internal Main.train, Main.validate #, Main.predict

end # module
