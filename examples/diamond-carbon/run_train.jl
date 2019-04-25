include("prepare.jl")

datalist = data_training()
config = configure()

results = Seer.train(datalist, config; datatype = Seer.DataFile.VASP)
