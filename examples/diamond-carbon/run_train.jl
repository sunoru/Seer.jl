include("prepare.jl")

data = data_training()
config = configure()

results = Seer.train(data, config)
