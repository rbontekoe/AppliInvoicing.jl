module AppliInvoicing

greet() = print("Hello World!")

export create, process

include("./infrastructure/infrastructure.jl")

end # module
