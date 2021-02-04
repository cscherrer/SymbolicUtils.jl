##### Numeric simplification

"""
simplify(x; rewriter=default_simplifier(),
            threaded=false,
            polynorm=true,
            thread_subtree_cutoff=100)

Simplify an expression (`x`) by applying `rewriter` until there are no changes.
`polynorm=true` applies `polynormalize` in the beginning of each fixpoint iteration.
"""
function simplify(x;
                  polynorm=false,
                  threaded=false,
                  thread_subtree_cutoff=100,
                  rewriter=nothing)
    f = if rewriter === nothing
        if threaded
            threaded_simplifier(thread_subtree_cutoff)
        elseif polynorm
            serial_polynormal_simplifier
        else
            serial_simplifier
        end
    else
        Fixpoint(rewriter)
    end

    PassThrough(f)(x)
end

Base.@deprecate simplify(x, ctx; kwargs...)  simplify(x; rewriter=ctx, kwargs...)

"""
    substitute(expr, dict)

substitute any subexpression that matches a key in `dict` with
the corresponding value.
"""
function substitute(expr, dict; fold=true)
    haskey(dict, expr) && return dict[expr]

    if istree(expr)
        if fold
            canfold=true
            args = map(arguments(expr)) do x
                x′ = substitute(x, dict; fold=fold)
                canfold = canfold && !(x′ isa Symbolic)
                x′
            end
            canfold && return operation(expr)(args...)
            args
        else
            args = map(x->substitute(x, dict), arguments(expr))
        end
        similarterm(expr, operation(expr), args)
    else
        expr
    end
end

# If there's only one key, a Pair has much less overhead than a Dict
function substitute(expr, Δ::Pair; fold=true)
    (old, new) = Δ

    if old === expr 
        return new
    end

    if istree(expr)
        if fold
            canfold=true
            args = map(arguments(expr)) do x
                x′ = substitute(x, Δ; fold=fold)
                canfold = canfold && !(x′ isa Symbolic)
                x′
            end
            canfold && return operation(expr)(args...)
            args
        else
            args = map(x->substitute(x, Δ), arguments(expr))
        end
        similarterm(expr, operation(expr), args)
    else
        expr
    end
end
