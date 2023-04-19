import Distributions
using TDLM
using TDLM.Simulate

@testset "RandomSequence" begin
    d1 = Distributions.MvNormal(rand_cov(5))
    d2 = 1:5
    s1 = RandomSequence(d1)
    s2 = RandomSequence(d2)
    @test size(s1) == (5, Inf)
    @test eltype(s1) == Vector{eltype(d1)}
    @test size(s2) == (1, Inf)
    @test eltype(s2) == Vector{eltype(d2)}
    @test size(s1[1:5, :]) == (5, 5)
    @test Base.IteratorSize(s1) == Base.IsInfinite()
end