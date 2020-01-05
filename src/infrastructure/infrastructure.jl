include("../api/api.jl")

db = connect()

archive(invoices::Array{UnpaidInvoice, 1}) = create(db, "UNPAID",invoices)

#archive(invoices::Array{PaidInvoice, 1}) = create(db, "PAID", invoices)
