module Utils

macro type_enum(name, expr)
    @assert expr isa Expr
    types = Symbol[]
    for (i, sym) in enumerate(expr.args)
        if sym isa Symbol
            expr.args[i] = :(struct $sym <: $name end)
        end
    end
    insert!(expr.args, 1,:(abstract type $name end))
    esc(expr)
end

macro export_internal(expr)
    @assert expr isa Expr
    const_export(expr) = begin
        sym = expr.args[end].value
        quote
            const $sym = $expr
            export $sym
        end
    end
    if expr.head === :tuple
        results = quote end
        results.args = [const_export(subexpr) for subexpr in expr.args]
        return esc(results)
    end
    @assert expr isa Expr && expr.head === :.
    esc(const_export(expr))
end

end
