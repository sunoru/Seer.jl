include("prepare.jl")

datalist = data_validate()
config = configure(true)

results = Seer.validate(datalist, config; datatype = Seer.DataFile.VASP)
