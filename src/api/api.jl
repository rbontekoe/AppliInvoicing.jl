# api.jl

include("../domain/domain.jl")

using AppliSales
import AppliSales.Order

create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
    return UnpaidInvoice(invoice_id, meta, header_invoice, body_invoice)
end

create(invoice::UnpaidInvoice, stm::BankStatement)::PaidInvoice = begin
	id = invoice.id
	meta = invoice.meta
	header = invoice.header
	body = invoice.body
	stm = stm
	return PaidInvoice(id, meta, header, body, stm)
end

function conv2entry(inv::UnpaidInvoice, from::Int, to::Int)
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = inv.header.name
    invoice_nbr = inv.header.invoice_nbr
    from = from
    to = to
    debit = inv.body.price_per_student * length(inv.body.students)
    credit = 0.0
    vat = debit * inv.body.vat_perc
    descr = inv.body.name_training
    return create_journal_entry(id, customer_id, invoice_nbr, from, to, debit, credit, vat, descr)
end

function conv2entry(inv::PaidInvoice, from::Int, to::Int)
    id = string(Date(now())) * "-" * string(global n += 1)
    customer_id = inv.header.name
    invoice_nbr = inv.header.invoice_nbr
    from = from
    to = to
    debit = 0.0
    credit = inv.body.price_per_student * length(inv.body.students)
    vat = credit * inv.body.vat_perc
    descr = inv.body.name_training
    return create_journal_entry(id, customer_id, invoice_nbr, from, to, debit, credit, vat, descr)
end
