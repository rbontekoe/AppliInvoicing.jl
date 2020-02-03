# api.jl

include("../domain/domain.jl")

import AppliSales.Order # Order is not exported but is refered to in the next function

# create unpaid invoices from an order
create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
	return UnpaidInvoice(invoice_id, meta, header_invoice, body_invoice)
end

# create paid invoice from a bank statement
create(invoice::UnpaidInvoice, stm::BankStatement)::PaidInvoice = begin
	id = invoice.id
	meta = invoice.meta
	header = invoice.header
	body = invoice.body
	stm = stm
	return PaidInvoice(id, meta, header, body, stm)
end

# create journal entries from an unpaid invoice
# the create_journal_entry function is exported by AppliGeneralLedger
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

# create journal entries from a paid invoice
# the create_journal_entry function is exported by AppliGeneralLedger
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
