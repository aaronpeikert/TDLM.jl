using TDLM
using Documenter
import Literate

mdpath = mkpath("./docs/src/md/")
long = "docs/src/long"
# get all files
mdsource = long*"/" .* readdir(long)
# convert to md
Literate.markdown.(mdsource, [mdpath]; documenter = true)
Literate.script.(mdsource, [mdpath]; preprocess = x -> replace(x, "\n\n" => ""))


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
        "Translation eLife" => "md/eLife.md"
    ],
    doctest = false, # use :fix to auto fix.
)

deploydocs(;
    repo="github.com/aaronpeikert/TDLM.jl",
    devbranch = "devel",
    push_preview = "push_preview=true" ∈ ARGS
)

