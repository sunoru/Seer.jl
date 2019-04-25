using Seer

cd("../examples/diamond-carbon") do
    include(joinpath(pwd(), "run_train.jl"))
end
