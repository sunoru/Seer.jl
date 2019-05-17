import ..DataFile

struct Energy <: NetworkOutputType
    value::Float64
end

valueof(e::Energy) = e.value
