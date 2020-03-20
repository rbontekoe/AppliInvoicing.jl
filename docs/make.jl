include("../src/infrastructure/infrastructure.jl")

using Documenter

makedocs(
    sitename = "Invoicing",
    format = Documenter.HTML(),
    pages = [
        "Invoicing" => "index.md",
        "1 - Domain" => "chapter1.md",
        "2 - API" => "chapter2.md",
        "3 - Infrastructure" => "chapter3.md",
        "4 - Examples" => "chapter4.md"
    ]
)
