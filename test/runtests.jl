cp("../docs/Manifest.toml", "./Manifest.toml", force=true)

using TDLM
using Test
using Documenter

@testset "TDLM.jl" begin
    DocMeta.setdocmeta!(TDLM, :DocTestSetup, :(using TDLM); recursive=true)
    doctest(TDLM)
    include("Simulate/Simulate.jl")
end
