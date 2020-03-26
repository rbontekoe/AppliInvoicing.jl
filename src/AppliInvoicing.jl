module AppliInvoicing

greet() = print("Hello World!")

using Dates

using AppliSales: Order

using AppliGeneralLedger: JournalEntry

export create, process, retrieve_unpaid_invoices, retrieve_paid_invoices, read_bank_statements

include("./infrastructure/infrastructure.jl")

end # module
