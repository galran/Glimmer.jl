
using Documenter
using Glimmer, Glimmer.FlexUI

makedocs(
    sitename = "Glimmer.jl",
    format = Documenter.HTML(
        # prettyurls = get(ENV, "CI", nothing) == "true",
        assets = [asset("assets/GlimmerJulia.png", class = :ico, islocal = true)],
    ),
    modules = [Glimmer],
    pages = [
        "Home" => "index.md",
    ],
    expandfirst = [])

# deploydocs(
#     repo = "github.com/galran/Glimmer.jl.git",
#     devbranch = "main",
#     push_preview = true,
#     target = "build",
#     deps = nothing,
#     make = nothing,    
# )

deploydocs(
    repo = "github.com/galran/Glimmer.jl.git",
    branch = "gh-pages",
    devbranch = "main",
    push_preview = true,
)