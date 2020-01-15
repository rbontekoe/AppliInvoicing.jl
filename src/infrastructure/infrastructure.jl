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

    # create journal statements - DUMMY DATA
    entry1 = create_journal_entry(string(Date(now())) * "-" * string(global n += 1), "Scrooge Investment Bank", "Invoice A1001", 1300, 8000, 1000.0, 0.0, 210.0, "Learn Smiling")
    entry2 = create_journal_entry(string(Date(now())) * "-" * string(global n += 1), "Duck City Chronicals", "Invoice A1002", 1300, 8000, 2000.0, 0.0, 420.0, "Smile")
    entry3 = create_journal_entry(string(Date(now())) * "-" * string(global n += 1), "Donalds Hardware Store", "Invoice A1003", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
    entries = [entry1, entry2, entry3]
    return entries

end

#process(bankstm::Array(Bankstatement, 1) = begin
process() = begin
    #db = connect("./invoicing.sqlite")

    # read JBankStatements converted to Journal Entries  - DUMMY DATA
    bstm1 = create_journal_entry(string(Date(now())) * "-" * string(global n += 1), "Duck City Chronicals", "Invoice A1002", 1150, 1300, 2420.0, 0.0, 0.0, "LS")
    bstm2 = create_journal_entry(string(Date(now())) * "-" * string(global n += 1), "Donalds Hardware Store","Bill A1003", 1150, 1300, 1210.0, 0.0, 0.0, "LS")
    stms = [bstm1, bstm2]

    #archive(db, "LEDGER", stms)

    return stms
end
