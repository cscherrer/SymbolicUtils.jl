using SymbolicUtils

using SymbolicUtils: FnType, Symbolic, Sym, symtype
import Base

struct Lambda{X,Y,SY} <: Symbolic{FnType{Tuple{X}, Y}}
    x :: Sym{X}
    y :: SY
end

export ↦ 

↦(x::Sym{X}, y::SY) where {X, SY} = Lambda{X, symtype(y), SY}(x,y)

function normalize(λ::Lambda)
    newx = typeof(λ.x)(:___i___) # unlikely to appear in λ.y
    newy = substitute(λ.y, λ.x => newx)
    return newx ↦ newy
end



function Base.hash(λ::Lambda{X,Y,SY}) where {X,Y,SY}
    newλ = normalize(λ)
    hash(:Lambda) + hash(X) + hash(Y) + hash(SY) + hash(newλ.y)
end


function Base.show(io::IO, λ::Lambda)
    print(io, "(", λ.x, " ↦ ", λ.y, ")")
end

Base.sum(λ::Lambda, x::AbstractArray) = term(sum, λ, x; type=symtype(λ.y))


istree(::Lambda) = true

operation(::Lambda) = ↦

arguments(λ::Lambda) = [λ.x, λ.y]

# similarterm(λ::Lambda, f, args[, T])

# @syms i::Int x::Real 

# λ = i ↦ i*x

# symtype(λ)

# sum(λ, 1:10)

# r = @rule sum(~i ↦ +(~~x), ~r) => +(sum(~i ↦ t, ~r) for t in ~~x)

# r(sum(i ↦ (i*x + i*x^2), 1:10)) |> isnothing
