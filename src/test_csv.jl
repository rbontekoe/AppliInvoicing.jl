include("./infrastructure/infrastructure.jl")

using CSV

# get orders

using AppliSales

orders = AppliSales.process()

# create unpaid invoices and store in db

db = connect("./invoicing.sqlite")

invoices = process(orders)

# read CSV with bank staements
df = CSV.read("bank.csv")

# create array with BankStatement's
stms = [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]

# get unpaid invoices
unpaid_records = retrieve(db, "UNPAID")

# convert dataframe to array with unpaid records
unpaid_invoices = [row[1] for row in eachrow(unpaid_records.item)]

# create array with potential paid invoices based on received bank statements
paid_invoices = []
for unpaid_invoice in unpaid_invoices
  for stm in stms # get potential paid invoices
    if occursin(unpaid_invoice.id, stm.descr) # row[2] = contains invoice number) # from DataFrame row
      push!(paid_invoices, create(unpaid_invoice, stm))
    end
  end
end

# convert to array with PaidInvoice's

paid_invoices = convert(Array{PaidInvoice, 1}, paid_invoices)

# archive PaidInvoice's

archive(db, "PAID", paid_invoices)

entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]

# read CSV with bank staements
df = CSV.read("bank.csv")

# create array with BankStatement's
stms = [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]
