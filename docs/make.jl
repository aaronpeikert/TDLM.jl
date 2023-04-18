using TDLM
using Documenter

DocMeta.setdocmeta!(TDLM, :DocTestSetup, :(using TDLM); recursive=true)

makedocs(;
    modules=[TDLM],
    authors="Aaron Peikert <aaron.peikert@posteo.de> and contributors",
    repo="https://github.com/aaronpeikert/TDLM.jl/blob/{commit}{path}#{line}",
    sitename="TDLM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
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
    devbranch="main",
)
