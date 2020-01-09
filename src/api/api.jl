# api.jl

include("../domain/domain.jl")

using AppliSales

create(order::Order, invoice_id::String)::UnpaidInvoice = begin
    meta = MetaInvoice(order.id, order.training.id)
    header_invoice = Header(
		    invoice_id, order.org.name, order.org.address, order.org.zip, order.org.city, order.org.country, order.order_ref, order.contact_name, order.contact_email)
    body_invoice = OpentrainingItem(order.training.name, order.training.date, order.training.price, order.students)
	#body_invoice = order.training
    invoice = UnpaidInvoice(invoice_id, meta, header_invoice, body_invoice)
end

create(invoice::UnpaidInvoice, stm::JournalStatement):: PaidInvoice = begin
	meta = invoice.meta
	header_invoice = invoice.header
	body_invoice = invoice.body
	stm = stm

	invoice = PaidInvoice(invoice.id, meta, header_invoice, body_invoice, stm)
end
