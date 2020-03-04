include("../src/infrastructure/infrastructure.jl")

using Documenter

makedocs(
    sitename = "Invoicing",
    format = Documenter.HTML(),
    pages = [
        "Invoicing" => "index.md",
        "1 - API" => "chapter1.md",
        "2 - Infrastructure" => "chapter2.md",
        "3 - Examples" => "chapter3.md"
    ]
)
