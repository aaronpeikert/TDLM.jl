import Base.+, Random
export +, Noise

"""
    Noise()

Add noise of a certain distribution to an array adopting the shape an structure of the array.
If nothing else specified, `randn` is used, otherwise it is sampled from the distribution.

```jldoctest
julia> using TDLM.Simulate

julia> zeros(3, 3) + Noise();

julia> ones(Int16, 3, 3) + Noise([1, 2, 3]);

julia> import Distributions

julia> zeros(3, 3) + Noise(Distributions.Beta());

julia> using StableRNGs # results above are suppressed, here reproducible:

julia> zeros(2, 2) + Noise(Distributions.Normal(), StableRNG(42))
2×2 Matrix{Float64}:
 -0.670252  1.37363
  0.447122  1.30954
```
"""
struct Noise{T}
    dist::T
    rng
    Noise(dist::T = missing, rng = Random.GLOBAL_RNG) where T = new{T}(dist, rng)
end
function add_noise!(X::AbstractArray, n::Noise)
    noise = ismissing(n.dist) ? randn(n.rng, length(X)) : rand(n.rng, n.dist, length(X))
    @inbounds for i in eachindex(X)
        X[i] =+ noise[i]
    end
    return X
end
add_noise(X::AbstractArray, n::Noise) = add_noise!(copy(X), n)
+(X::AbstractArray, n::Noise) = add_noise(X, n)
+(n::Noise, X::AbstractArray) = X + n