#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

#using AppliSales

org1 = create_org(
    "Scrooge Investment Bank",
    "1180 Seven Seas Dr",
    "FL 32830",
    "Lake Buena Vista",
    "USA")
org2 = create_org(
    "Duck City Chronicals",
    "1185 Seven Seas Dr",
    "FL 32830",
    "Lake Buena Vista",
    "USA")
org3 = create_org(
    "Donalds Hardware Store",
    "1190 Seven Seas Dr",
    "FL 32830",
    "Lake Buena Vista",
    "USA")

training = create_training("LS", DateTime(2019, 8, 30), 2, "Learn Smiling", 1000.0)

order1 = create_order(
    org1,
    training,
    "PO-456",
    "Scrooge McDuck",
    "scrooge@duckcity.com",
    ["Scrooge McDuck"])
order2 = create_order(
    org2,
    training,
    "DD-001",
    "Mickey Mouse",
    "mickey@duckcity.com",
    ["Mini Mouse", "Goofy"])
order3 = create_order(
    org3,
    training,
    "",
    "Donald Duck",
    "donald@duckcity.com",
    ["Daisy Duck"])

invoice1 = create(order1, "A1001")
invoice2 = create(order2, "A1002")
invoice3 = create(order3, "A1003")

include("./print_invoice.jl")

show_invoice(invoice1)
show_invoice(invoice2)
show_invoice(invoice3)

# Save unpaid invoice
using AppliSQLite
db = connect()
archive(db, "UNPAID", [invoice1, invoice2, invoice3])
unpaid_invoices = retrieve(db, "UNPAID")
println(unpaid_invoices)

# create journal statement for invoices send (CONVERT INVOICE TO STATEMENT!!!!!)
using AppliGeneralLegder
stm1 = create_statemnent("20200702", "Scrooge Investment Bank", "Invoice A1001", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
stm2 = create_statemnent("20200702", "Duck City Chronicals", "Invoice A1002", 1300, 8000, 2000.0, 0.0, 420.0, "LS")
stm3 = create_statemnent("20200702", "Donalds Hardware Store", "Invoice A1003", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
archive(db, "JOURNAL", [stm1, stm2, stm3])
r = retrieve(db, "JOURNAL")
println(r)

book(db, "LEDGER", stm1)
book(db, "LEDGER", stm2)
book(db, "LEDGER", stm3)
r = retrieve(db, "LEDGER")
println(r)

# create journal statement for bank statements
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
