export random_length

"""
    random_length(xs::I, dist; fun = first, rng = Random.GLOBAL_RNG)

`random_length` wraps a sequence but returns the first `n` elements, where `n` is choosen randomly based on `dist`.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> S = random_length(1:100, [1 3]; rng = StableRNG(42));

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
random_length(args...; nargs...) = RandomLength(args...; nargs...)

struct RandomLength{I}
    xs::I
    dist
    fun
    rng
    function RandomLength(xs::I, dist; fun = first, rng = Random.GLOBAL_RNG) where I
        new{I}(xs, dist, fun, rng)
    end
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
