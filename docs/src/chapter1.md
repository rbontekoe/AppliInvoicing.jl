# 2. Domain structure and functions

## Domain structure

The function `subtypetree` is from the book [Design Patterns and Best Practices with Julia](https://www.amazon.com/Hands-Design-Patterns-Julia-comprehensive/dp/183864881X)

Branches are abstract data types, and the leaves are concrete data types.

```
julia> subtypes(Invoice)
2-element Array{Any,1}:
 PaidInvoice  
 UnpaidInvoice

julia> subtypetree(Domain)
Domain
    Invoice
        PaidInvoice
        UnpaidInvoice
    Payment
        BankStatement
    Structure
        BodyItem
            OpentrainingItem
        Header
        MetaInvoice
```

## Accessor functions for Invoice
```
meta(i::Invoice)::MetaInvoice
header(i::Invoice)::Header
body(i::Invoice)::BodyItem
id(i::Invoice)::String
```

## Accessor functions for MetaInvoice
```
order_id(m::MetaInvoice)::String
training_id(m::MetaInvoice)::String
date(m::MetaInvoice)::DateTime
currency(m::MetaInvoice)::String
currency_ratio(m::MetaInvoice)::Float64
```

## Accessor functions for Header
```
invoice_nbr(h::Header)::String
name(h::Header)::String
address(h::Header)::String
zip(h::Header)::String
city(h::Header)::String
country(h::Header)::String
order_ref(h::Header)::String
name_contact(h::Header)::String
email_contact(h::Header)::String
```

## Accessor functions for Opentraining
```
name_training(o::OpentrainingItem)::String
date(o::OpentrainingItem)::DateTime
price_per_student(o::OpentrainingItem)::Float64
students(o::OpentrainingItem)::Array{String, 1}
vat_perc(o::OpentrainingItem)::Float64
```

## Accessor function for BankStatement
```
date(b::BankStatement)::Date
descr(b::BankStatement)::String
iban(b::BankStatement)::String
amount(b::BankStatement)::Float64
```

## Example
```
julia> include("./src/infrastructure/infrastructure.jl");

julia> const PATH_DB_TEST = "./test_invoicing.sqlite";

julia> const PATH_CSV = "./bank.csv";

julia> orders = AppliSales.process(); # get the orders

julia> invnbr = 1000; # set starting invoice number

julia> journal_entries_1 = process(orders; path=PATH_DB_TEST); # # process the orders

julia> stms = read_bank_statements(PATH_CSV); # retrieve the bank statemnets

julia> unpaid_invoices = retrieve_unpaid_invoices(path=PATH_DB_TEST); # retrieve the unpaid invoices

julia> id(unpaid_invoices[2]) # we will receive a payment for invoice A1002 in a later step
"A1002"

julia> meta(unpaid_invoices[2])
MetaInvoice("13773275872094593946", "LS", 2020-03-31T10:29:36.885, "€", 1.0)

julia> header(unpaid_invoices[2])
Header("A1002", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "DD-001", "Mickey Mouse", "mickey@duckcity.com")

julia> body(unpaid_invoices[2])
OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Mini Mouse", "Goofy"], 0.21)

julia> journal_entries_2 = process(unpaid_invoices, stms; path=PATH_DB_TEST); # process the bank statements

julia> paid_invoices = retrieve_paid_invoices(path=PATH_DB_TEST); # retrieve the paid invoices

julia> id(paid_invoices[1]) # one of the paid invoices (see the step earlier retrieving the unpaid invoices)
"A1002"

julia> stm(paid_invoices[1])
BankStatement(2020-01-15, "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)

julia> cmd = `rm $(PATH_DB_TEST)`; # the Linux command to remove the database

julia> run(cmd); # execute the command
```
