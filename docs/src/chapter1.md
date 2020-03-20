# 2. Domain structure and functions

## Domain structure

The function subtypetree is from the book [Design Patterns and best Practices with Julia](https://www.amazon.com/Hands-Design-Patterns-Julia-comprehensive/dp/183864881X)

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

julia> fieldnames(PaidInvoice)
(:id, :meta, :header, :body, :stm)

julia> fieldnames(UnpaidInvoice)
(:id, :meta, :header, :body)
```

## Field name functions for Invoice

## id
```@docs
id
```

## meta
```@docs
meta
```

## header
```@docs
header
```

## body
```@docs
body
```

## stm
```@docs
stm
```

## Example
```
julia> include("./src/infrastructure/infrastructure.jl"); # link to the model

julia> const PATH_DB_TEST = "./test_invoicing.sqlite";

julia> const PATH_CSV = "./bank.csv";

julia> orders = AppliSales.process(); # get the order

julia> invnbr = 1000; # set starting invoice number

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]; # create the invoices

julia> journal_entries_1 = process(PATH_DB_TEST, orders); # #process the orders

julia> stms = read_bank_statements(PATH_CSV); # retrieve the bank statemnets

julia> unpaid_invoices = retrieve_unpaid_invoices(PATH_DB_TEST); # retrieve the unpaid invoices

julia> id(unpaid_invoices[2]) # we will receive a payment for invoice A1002 in a later step
"A1002"

julia> header(unpaid_invoices[2])
Header("A1002", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "DD-001", "Mickey Mouse", "mickey@duckcity.com")

julia> body(unpaid_invoices[2])
OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Mini Mouse", "Goofy"], 0.21)

julia> stm(unpaid_invoices[2]) # unpaid invoice doesn't have a field stm
ERROR: MethodError: no method matching stm(::UnpaidInvoice)
Closest candidates are:
  stm(::PaidInvoice) at /home/rob/julia-projects/tc/AppliInvoicing/src/domain/domain.jl:75

julia> journal_entries_2 = process(PATH_DB_TEST, unpaid_invoices, stms); # process the bank statements

julia> paid_invoices = retrieve_paid_invoices(PATH_DB_TEST); # retrieve the paid invoices

julia> id(paid_invoices[1]) # one of the paid invoices, see the step above retrieve the unpaid invoices
"A1002"

julia> header(paid_invoices[1])
Header("A1002", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "DD-001", "Mickey Mouse", "mickey@duckcity.com")

julia> body(paid_invoices[1])
OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Mini Mouse", "Goofy"], 0.21)

julia> stm(paid_invoices[1])
BankStatement(2020-01-15, "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)

julia> cmd = `rm $(PATH_DB_TEST)`; # linux command to remove the database

julia> run(cmd); # execute the command
```
