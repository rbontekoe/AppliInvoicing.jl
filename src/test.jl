#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

using AppliSales

invoices = AppliSales.process()

result = process(invoices)

using AppliGeneralLegder

result2 = process()


# create journal statement for invoices send (CONVERT INVOICE TO STATEMENT!!!!!)
using AppliGeneralLegder
stm1 = create_statemnent("20200702", "Scrooge Investment Bank", "Invoice A1001", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
stm2 = create_statemnent("20200702", "Duck City Chronicals", "Invoice A1002", 1300, 8000, 2000.0, 0.0, 420.0, "LS")
stm3 = create_statemnent("20200702", "Donalds Hardware Store", "Invoice A1003", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
archive(db, "JOURNAL", [stm1, stm2, stm3])
r = retrieve(db, "JOURNAL")
println(r)

#import AppliGeneralLegder.book
AppliGeneralLegder.book(db, "LEDGER", stm1)

book(db, "LEDGER", stm2)
book(db, "LEDGER", stm3)
r = retrieve(db, "LEDGER")
println(r)

# create journal statement from bank statements
bstm1 = create_statemnent("20200702", "Duck City Chronicals", "Invoice A1002", 1150, 1300, 2420.0, 0.0, 0.0, "LS")
bstm2 = create_statemnent("20200703", "Donalds Hardware Store","Bill A1003", 1150, 1300, 1210.0, 0.0, 0.0, "LS")
r = archive(db, "JOURNAL", [bstm1, bstm2])
println(r)

# book payments in general ledger
book(db, "LEDGER", bstm1)
book(db, "LEDGER", bstm2)
r = retrieve(db, "LEDGER")
println(r)

# get the invoices that ware paid
result = []
for entry in [bstm1, bstm2]
    r = filter(x -> occursin(x.header.invoice_nbr, entry.invoice_nbr), unpaid_invoices.item)
    push!(result, create(r[1], entry))
end

# save the paid invoices
paid_invoices = convert(Array{PaidInvoice, 1}, result)

archive(db, "PAID", paid_invoices)

r = retrieve(db, "PAID")

println(r.item)

#f(x) = x^2

#runfunction(funct, x) = f(x)
