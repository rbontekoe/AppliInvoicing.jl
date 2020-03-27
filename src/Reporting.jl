# Reporting.jl

module Reporting


const PATH_DB = "./invoicing.sqlite"

using Dates

using AppliInvoicing

aging() = begin
    unpaid_invoices = AppliInvoicing.retrieve_unpaid_invoices(PATH_DB)
    list = []
    for invoice in unpaid_invoices
        date = invoice.meta.date
        println(date, " - ", Dates.today())
    end
end # aging

end # module
