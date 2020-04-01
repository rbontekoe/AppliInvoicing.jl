module AppliInvoicing

greet() = print("Hello World!")

export create, process, retrieve_unpaid_invoices, retrieve_paid_invoices, read_bank_statements, report

export id, meta, header, body, stm

# first, link to the model
include("./infrastructure/infrastructure.jl")

# next, submodule Reporting
include("Reporting.jl")
using .Reporting: aging

end # module
