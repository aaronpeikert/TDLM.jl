import Random
import LinearAlgebra: eigen, diagm, Symmetric
export rand_cov
"""
    rand_cov(k::Int, [rng = Random.GLOBAL_RNG])

Generate a random covariance matrix of size `k×k`.

```jldoctest; setup = :(using StableRNGs)
julia> using TDLM.Simulate

julia> rand_cov(3, StableRNGs.StableRNG(42))
3×3 LinearAlgebra.Symmetric{Float64, Matrix{Float64}}:
  1.39477     0.156631   -0.0456395
  0.156631    1.54293    -0.0163959
 -0.0456395  -0.0163959   0.797937
```

"""
function rand_cov(k::Int, rng = Random.GLOBAL_RNG)
    A = randn(rng, k, k)
    _, U = eigen((A+A')/2)
    Symmetric(U*diagm(abs.(randn(rng, k)))*U')
end
