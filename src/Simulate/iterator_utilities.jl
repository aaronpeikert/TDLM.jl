export RandomLength, Chain


"""
RandomLength(xs, dist)

`RandomLength` wraps a sequence but returns the first `n` elements, where `n` is choosen randomly based on `dist`.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = RandomLength(1:100, [1 3]; rng = StableRNG(42));

julia> collect(S)
3-element Vector{Int64}:
 1
 2
 3 
julia> collect(S)
1-element Vector{Int64}:
 1
```
"""
struct RandomLength{I}
    xs::I
    dist
    fun
    rng
    RandomLength(xs::I, dist; fun = first, rng = Random.GLOBAL_RNG) where I = new{I}(xs, dist, fun, rng)
end

function Base.iterate(S::RandomLength, state = (S.fun(rand(S.rng, S.dist, 1)), ))
    n, rest = state[1], Iterators.tail(state)
    n <= 0 && return nothing
    y = iterate(S.xs, rest...)
    y === nothing && return nothing
    return y[1], (n - 1, y[2])
end

Base.eltype(::Type{RandomLength{T}}) where {T} = eltype(T)
Base.IteratorSize(::Type{RandomLength{T}}) where {T} = Base.SizeUnknown()

"""
    Chain(iterators...)

Chain simply connects iterators but instead of collecting them, it returns again an iterator.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = Chain(1:2, 100:102)
Chain{Tuple{UnitRange{Int64}, UnitRange{Int64}}}((1:2, 100:102))
julia> collect(S)
5-element Vector{Int64}:
   1
   2
 100
 101
 102
```
"""
struct Chain{Is}
    is::Is
end

Chain(i...) = Chain(i)

function Base.iterate(S::Chain, state = (1, ))
    n, rest = state[1], Iterators.tail(state)
    length(S.is) < n && return nothing
    result = iterate(S.is[n], rest...)
    if result === nothing
        return iterate(S, (n + 1, ))
    else
        return result[1], (n, result[2])
    end
end

Base.IteratorSize(::Type{Chain{T}}) where {T} = Base.SizeUnknown()
function Base.eltype(::Type{Chain{T}}) where {T}
    promote_type(map(eltype, fieldtypes(T))...)
end
