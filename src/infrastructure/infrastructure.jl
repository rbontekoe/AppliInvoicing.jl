# infrastructure.jl

using CSV
using DataFrames

include("../api/api.jl")
include("./db.jl") # database functions

@enum TableName begin
    UNPAID
    PAID
end # enumerator for TableName types

# get last statement number for today
n = 0

process(path, orders::Array{Order, 1}) = begin
    # connect to db
    db = connect(path)

    # get last order number
    invnbr = 1000 #ToDo

    # create invoices
    invoices = [create(order, "A" * string(invnbr += 1)) for order in orders]

    # archive invoices
    archive(db, string(UNPAID), invoices)

    # create journal entries from invoices
    return entries = [conv2entry(inv, 1300, 8000) for inv in invoices]
end # process(path, orders::Array{Order, 1})

#process(bankstm::Array(Bankstatement, 1) = begin
process(path, invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1}) = begin
    # connect to db
    db = connect(path)

    # create array with potential paid invoices based on received bank statements
    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for stm in stms # get potential paid invoices
        if occursin(unpaid_invoice.id, stm.descr) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, stm))
        end
      end
    end

    # convert to an array with PaidInvoice's
    paid_invoices = convert(Array{PaidInvoice, 1}, potential_paid_invoices)

    # archive PaidInvoice's
    archive(db, string(PAID), paid_invoices)

    # return array with JournalEntry's
    return entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]
end # process(path, invoices::Array{UnpaidInvoice, 1}, stms::Array{BankStatement, 1})

read_bank_statements(path::String) = begin
    # read the CSV file containing bank statements
    df = CSV.read(path) # returns a DataFrame

    # return an array with BankStatement's
    # row[1] is the first value of row, row[2] the second value, etc.
    return [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]
end # read_bank_statements

retrieve_unpaid_invoices(path)::Array{UnpaidInvoice, 1} = begin
    # connect to db
    db = connect(path)

    # retrieve unpaid invoices as dataframe
    unpaid_records = retrieve(db, string(UNPAID))

    # convert the dataframe to an array with UnpaidInvoice's.
    # row is an array with one element, which is an array.
    # row[1] is the the content of the element, the UnpaidInvoice.
    unpaid_invoices = [row[1] for row in eachrow(unpaid_records.item)]

    # return the array with UnpaidInvoice's that
    return unpaid_invoices
end # retrieve_unpaid_invoices
