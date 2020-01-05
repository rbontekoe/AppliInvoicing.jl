# general_ledger.jl

struct Entry
    date::DateTime
    name::String
    descr::String
    amount::Float64
end

struct BankStatement
    stmno::Int64
    entries::Array{Entry, 1}
end

struct JournalStatement
    period::Int64
    date::Date
    invoice_nbr::String
    stm_nbr::Int64
    from::Int64
    to::Int64
    debit::Float64
    credit::Float64
    vat::Float64
    descr::String
    # constructors
    JournalStatement(period, date, invoice_nbr, stm_nbr, from, to, debit, credit, vat, descr) =
    new(period, date, invoice_nbr, stm_nbr, from, to, debit, credit, vat, descr)
end

struct LedgerAccount
    date::DateTime
    customerid::String
    invoice_nbr::String
    stm_nbr::String
    debit::Float64
    credit::Float64
    descr::String
end
