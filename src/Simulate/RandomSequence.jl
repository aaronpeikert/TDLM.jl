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

```jldoctest; setup = :(using StableRNGs)
julia> import Distributions

julia> s1 = RandomSequence(Distributions.MvNormal(rand_cov(2)); rng = StableRNG(42));

julia> s1[1:100, :] # sequence is infinite, simply index as much as you need
100×2 Matrix{Float64}:
 -0.589181   0.291201
  0.618301   1.4553
  0.729122   2.00813
 -0.166802   1.28532
  1.39326    2.47718
  ⋮         
 -6.539     -0.143812
 -6.87956   -1.17514
 -8.02183   -2.12672
 -8.22977   -1.72463

julia> # dist can also be a vector, and mix can be an abitrary function

julia> RandomSequence([2 4], (prev, next) -> next - prev; rng = StableRNG(43))[1:5, :]
5×1 Matrix{Int64}:
 4
 0
 2
 0
 2
 ```
"""
struct RandomSequence{T1, T2}
    dist::T1
    mix::T2
    rng
    function RandomSequence(dist::T1, mix::T2 = default_mix; rng = Random.GLOBAL_RNG) where {T1 <: Union{AbstractArray, Sampleable}, T2 <: Function}
        new{T1, T2}(dist, mix, rng)
    end
end
function Base.iterate(S::RandomSequence, prev = zeros(eltype(eltype(S)), size(S, 1)))
    state = vec(S.mix(prev, rand(S.rng, S.dist, 1)))
    (state, state)
end
Base.IteratorSize(::Type{RandomSequence}) = Base.IsInfinite()
Base.eltype(::Type{RandomSequence{T1, T2}}) where {T1, T2} = Vector{eltype(T1)}
Base.size(S::RandomSequence{T}) where {T <: Sampleable} = (length(S.dist), Inf)
Base.size(::RandomSequence{T}) where {T <: AbstractArray} = (1, Inf)
Base.size(S::RandomSequence, d::Integer) = size(S)[convert(Int, d)]
function Base.getindex(S::RandomSequence, i::Union{Int, AbstractVector}, j)
    permutedims(reshape(collect(Iterators.flatten(Iterators.take(S, maximum(i)))), :, maximum(i)))[i, j]
end
