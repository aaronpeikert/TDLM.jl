import Distributions: Sampleable
import Random
export RandomSequence, default_mix

"""
    default_mix(prev, next)

The default mix function simply adds together `prev` and `next`, overwriting next.
"""
function default_mix(prev, next)
    @. next = next + prev
end

"""
    RandomSequence(dist::Union{AbstractArray, Sampleable}, [mix_fun]; [rng])

RandomSequence produces an infinite sequence of random numbers on demand.
Each step of the sequence is sampled from dist, the next step is a combination of the previos step as well as new random numbers.
The combination is determined by a function.
If no function is is given, they will simply be added.

```jldoctest; setup = :(using TDLM.Simulate, StableRNGs)
julia> import Distributions

julia> s1 = RandomSequence(Distributions.MvNormal(rand_cov(2, rng = StableRNG(42))); rng = StableRNG(42));

julia> s1[1:100, :] # sequence is infinite, simply index as much as you need
100×2 Matrix{Float64}:
 -0.299517    0.0105985
  0.314321    1.45151
  0.370658    1.95421
 -0.0847956   1.00213
  0.708281    2.60451
  ⋮          
 -3.32418    -2.6863
 -3.49731    -3.67663
 -4.07799    -4.91543
 -4.1837     -4.66306

julia> # dist can also be a vector, and mix can be an abitrary function

julia> RandomSequence([2 4], mix = (prev, next) -> next - prev, rng = StableRNG(43))[1:5, :]
5×1 Matrix{Int64}:
 4
 0
 2
 0
 2
```
"""
struct RandomSequence{T}
    dist::T
    mix::Function
    rng
    function RandomSequence(dist::T; mix = default_mix, rng = Random.GLOBAL_RNG) where {T <: Union{AbstractArray, Sampleable}}
        new{T}(dist, mix, rng)
    end
end
function Base.iterate(S::RandomSequence, prev = zeros(eltype(eltype(S)), size(S, 1)))
    state = vec(S.mix(prev, rand(S.rng, S.dist, 1)))
    (state, state)
end
Base.IteratorSize(::Type{RandomSequence{T}}) where {T} = Base.IsInfinite()
Base.eltype(::Type{RandomSequence{T}}) where {T} = Vector{eltype(T)}
Base.size(S::RandomSequence{T}) where {T <: Sampleable} = (length(S.dist), Inf)
Base.size(::RandomSequence{T}) where {T <: AbstractArray} = (1, Inf)
Base.size(S::RandomSequence, d::Integer) = size(S)[convert(Int, d)]
function Base.getindex(S::RandomSequence, i::Union{Int, AbstractVector}, j)
    permutedims(reshape(collect(Iterators.flatten(Iterators.take(S, maximum(i)))), :, maximum(i)))[i, j]
end
