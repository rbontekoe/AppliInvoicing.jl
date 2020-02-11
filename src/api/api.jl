# api.jl

include("../domain/domain.jl")

import AppliSales.Order # Order is not exported but is refered to in the next function

"""
    create(order::Order, invoice_id::String)::UnpaidInvoice

Create a UnpaidInvoice from an AppliSales.Order

# Example
```jldoctest
julia> using AppliInvoicing

julia> using AppliSales

julia> orders = AppliSales.process()

julia> invnbr = 1000

julia> invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]
```
"""
create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
	return UnpaidInvoice(invoice_id, meta, header_invoice, body_invoice)
end

"""
    create(invoice::UnpaidInvoice, stm::BankStatement)::PaidInvoice

Create a PaidInvoice from an UnpaidInvoice.

# Example
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
```
"""
create(invoice::UnpaidInvoice, stm::BankStatement)::PaidInvoice = begin
	id = invoice.id
	meta = invoice.meta
	header = invoice.header
	body = invoice.body
	stm = stm
	return PaidInvoice(id, meta, header, body, stm)
end


"""
    function conv2entry(inv::UnpaidInvoice, from::Int, to::Int)

convert unpaid invoice into an AppliGeneralLedger.JournalEntry including VAT.

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
```
"""
function conv2entry(inv::UnpaidInvoice, from::Int, to::Int)
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = inv.header.name
    invoice_nbr = inv.header.invoice_nbr
    debit = inv.body.price_per_student * length(inv.body.students)
    credit = 0.0
    vat = debit * inv.body.vat_perc
    descr = inv.body.name_training
    return create_journal_entry(id, customer_id, invoice_nbr, from, to, debit, credit, vat, descr)
end


"""
    function conv2entry(inv::PaidInvoice, from::Int, to::Int)

convert paid invoices into an AppliGeneralLedger.JournalEntry.
"""
function conv2entry(inv::PaidInvoice, from::Int, to::Int)
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = inv.header.name
    invoice_nbr = inv.header.invoice_nbr
    debit = inv.stm.amount
    credit = 0.0
    vat = 0.0
    descr = inv.body.name_training
    return create_journal_entry(id, customer_id, invoice_nbr, from, to, debit, credit, vat, descr)
end
