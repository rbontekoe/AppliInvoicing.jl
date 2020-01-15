# api.jl

include("../domain/domain.jl")

using AppliSales
import AppliSales.Order

create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
	#body_invoice = order.training
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
