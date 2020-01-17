#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

using AppliSales

orders = AppliSales.process()

journal_entries_unpaid_invoices = process(orders)

journal_entries_paid_invoices = process()
