# doc,jl - api

"""
    create(::AppliSales.Order, invoice_id::String)::UnpaidInvoice

    create(::UnpaidInvoice, ::AppliGeneralLedger.BankStatement)::PaidInvoice

- Create an UnpaidInvoice from an AppliSales.Order.
- Create a PaidInvoice from an UnpaidInvoice and a BankStatement.

@see also [`conv2entry`](@ref)

# Example - create an UnpaidInvoice
```jldoctest
julia> using AppliInvoicing

julia> using AppliSales

julia> orders = AppliSales.process()

julia> invnbr = 1000

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```

# Example - create a PaidInvoice
```jldoctest
julia> using Dates

julia> using AppliInvoicing

julia> using AppliSales

julia> orders = AppliSales.process()

julia> invnbr = 1000

julia> unpaid_invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]

julia> import AppliInvoicing.BankStatement

julia> stms = [BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)]

julia> potential_paid_invoices = []

julia> for unpaid_invoice in unpaid_invoices
    		for stm in stms # get potential paid invoices
        		if occursin(unpaid_invoice.id, stm.descr) # description contains invoice number
                	push!(potential_paid_invoices, create(unpaid_invoice, stm))
        		end
        	end
        end

julia> potential_paid_invoices

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```
"""
function create end

"""
    conv2entry(::UnpaidInvoice, from::Int, to::Int)

    conv2entry(::PaidInvoice, from::Int, to::Int)

Converts an invoice into AppliGeneralLedger.JournalEntry's.

@see also [`create`](@ref)

```jldoctest
julia> include("./src/api/api.jl");

julia using Dates

julia> using AppliSales

julia> using AppliGeneralLedger

julia> orders = AppliSales.process()

julia> invnbr = 1000

julia> unpaid_invoice = create(orders[1], "A" * string(invnbr += 1))

julia> n = 100

julia> journal_entries = conv2entry(unpaid_invoice, 1300, 8000)

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```
"""
function conv2entry end
