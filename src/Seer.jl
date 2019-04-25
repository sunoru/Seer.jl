module Seer

include("Utils.jl")

include("DataIO.jl")
Utils.@export_internal DataIO.DataFile, DataIO.load_data, DataIO.Data

include("NetworkInput.jl")
include("NetworkOutput.jl")
export NetworkInput, NetworkOutput

include("TrainingAlgorithms.jl")
export TrainingAlgorithms

include("Configurations.jl")
Utils.@export_internal Configurations.Config, Configurations.configure

include("Main.jl")
Utils.@export_internal Main.train, Main.validate #, predict

end # module
