#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

using AppliSales

orders = AppliSales.process()

journal_entries_unpaid_invoices = process(orders)

journal_entries_paid_invoices = process()

#==
using AppliGeneralLedger

AppliGeneralLedger.process(journal_entries_unpaid_invoices)

AppliGeneralLedger.process(journal_entries_paid_invoices)

using AppliSQLite

db = connect("./ledger.sqlite")

r1 = retrieve(db, "JOURNAL")
println(r1)

r2 = retrieve(db, "LEDGER")
println(r2)
==#
