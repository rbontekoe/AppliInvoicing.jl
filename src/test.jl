#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

using AppliSales

invoices = AppliSales.process()

result = process(invoices)

stms = process()

using AppliGeneralLedger

AppliGeneralLedger.process(result)

AppliGeneralLedger.process(stms)

using AppliSQLite

db = connect("./ledger.sqlite")

r1 = retrieve(db, "JOURNAL")

r2 = retrieve(db, "LEDGER")
