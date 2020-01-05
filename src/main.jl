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

# TODO Save unpaid invoice
archive([invoice1, invoice2, invoice3])
