using TDLM
using Documenter

DocMeta.setdocmeta!(TDLM, :DocTestSetup, :(using TDLM); recursive=true)

on_ci() = get(ENV, "CI", "false") == "true"

makedocs(;
    modules=[TDLM],
    authors="Aaron Peikert <aaron.peikert@posteo.de> and contributors",
    repo="https://github.com/aaronpeikert/TDLM.jl/blob/{commit}{path}#{line}",
    sitename="TDLM.jl",
    format=Documenter.HTML(;
        prettyurls=on_ci(),
        canonical="https://aaronpeikert.github.io/TDLM.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aaronpeikert/TDLM.jl",
    devbranch = "devel",
    push_preview = "push_preview=true" ∈ ARGS
)
