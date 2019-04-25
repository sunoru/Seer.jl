module Utils

macro type_enum(name, expr)
    @assert expr isa Expr
    types = Symbol[]
    for (i, sym) in enumerate(expr.args)
        if sym isa Symbol
            expr.args[i] = :(const $sym = Val{Symbol($(string(name, "_", sym)))})
            push!(types, sym)
        end
    end
    push!(expr.args, :(
        const $name = Union{$(types...)}
    ))
    esc(expr)
end


macro export_internal(expr)
    const_export(expr) = :(const $(expr.args[end].value) = $expr)
    @assert expr isa Expr
    if expr.head === :tuple
        results = quote end
        results.args = [const_export(subexpr) for subexpr in expr.args]
        return esc(results)
    end
    @assert expr isa Expr && expr.head === :.
    esc(const_export(expr))
end

end
