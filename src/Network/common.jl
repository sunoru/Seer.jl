import Random: AbstractRNG


function new_layer(n_in::Int, n_out::Int, transfer::Function, rng::AbstractRNG)
    Flux.Dense(n_in, n_out, transfer; initb = n -> randn(rng, n))
end
