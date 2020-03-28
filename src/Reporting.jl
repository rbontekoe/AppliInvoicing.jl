# Reporting.jl

module Reporting


const PATH_DB = "./invoicing.sqlite"

using Dates

using ..AppliInvoicing

struct Aging
    id_inv::String
    csm::String
    inv_date::Date
    amount::Float64
    days::Day
end

aging() = begin
    unpaid_invoices = AppliInvoicing.retrieve_unpaid_invoices(PATH_DB)
    paid_invoices = AppliInvoicing.retrieve_paid_invoices(PATH_DB)

    paid = [x.id for x in paid_invoices]
    unpaid = filter(x -> x.id ∉ paid, unpaid_invoices)

    list = []
    for invoice in unpaid
        id = invoice.id
        csm = invoice.header.name
        inv_date = Date(invoice.meta.date)
        b = invoice.body
        amount = (b.price_per_student * length(b.students)) * (1 + b.vat_perc)
        days = Dates.today() - inv_date
        aging_item = Aging(id, csm, inv_date, amount, days)
        push!(list, aging_item)
    end
    return list
end # aging

end # module
