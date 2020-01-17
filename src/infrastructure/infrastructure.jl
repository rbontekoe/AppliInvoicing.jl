include("../api/api.jl")

@enum TableName begin
    UNPAID
    PAID
end # defined enumerator for Publisher types

using AppliGeneralLedger
using AppliSQLite

# get last statement number for today
n = 0

process(orders::Array{Order, 1}) = begin
    db = connect("./invoicing.sqlite")

    # get last order number
    m = 1000

    # create invoices
    invoices = [create(order, "A" * string(m += 1)) for order in orders]

    # archive invoices
    archive(db, string(UNPAID), invoices)

    # create journal entries from invoices
    return entries = [conv2entry(inv, 1300, 8000) for inv in invoices]

end

#process(bankstm::Array(Bankstatement, 1) = begin
process(stms::Array{BankStatement, 1}) = begin

    # read CSV with bank staements
    df = CSV.read("bank.csv")

    # connect to database
    db = connect("./invoicing.sqlite")

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

    # return jarray with JournalEntry's

    return entries = [conv2entry(inv, 1150, 1300) for inv in paid_invoices]
end


read_bank_statements() = begin
    # read CSV with bank staements
    df = CSV.read("bank.csv")

    # create array with BankStatement's
    stms = [BankStatement(row[1], row[2], row[3], row[4]) for row in eachrow(df)]

    # return array
    return stms
end
