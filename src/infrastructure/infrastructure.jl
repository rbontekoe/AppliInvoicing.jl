include("../api/api.jl")

@enum TableName begin
    UNPAID
    PAID
end # defined enumerator for Publisher types

# Connect
#connect(path::String)::SQLite.DB = SQLite.DB(path)

#connect()::SQLite.DB = SQLite.DB()

# Create
#store(db::SQLite.DB, table::String, items::Array{T, 1} where {T <: Any}) = begin
#   DataFrame( items ) |> SQLite.load!(db, table)
#end # defined store

# retrieve
#retrieve(db::SQLite.DB, table::String)::DataFrame = SQLite.Query( db, "select * from $table") |> DataFrame

#retrieve(db::SQLite.DB, table::String, condition::String )::DataFrame = SQLite.Query( db, "select * from $table where $condition")  |> DataFrame

using AppliGeneralLegder
using AppliSQLite
using AppliSales

process(orders::Array{Order, 1}) = begin
    db = connect()
    # get last order number
    n = 1000
    # create invoices
    invoices = [create(order, "A" * string(n += 1)) for order in orders]
    # archive invoices
    archive(db, string(UNPAID), invoices)

    # create journal statements
    stm1 = create_statemnent("20200702", "Scrooge Investment Bank", "Invoice A1001", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
    stm2 = create_statemnent("20200702", "Duck City Chronicals", "Invoice A1002", 1300, 8000, 2000.0, 0.0, 420.0, "LS")
    stm3 = create_statemnent("20200702", "Donalds Hardware Store", "Invoice A1003", 1300, 8000, 1000.0, 0.0, 210.0, "LS")
    stms = [stm1, stm2, stm3]
    return stms

end

#process(bankstm::Array(Bankstatement, 1) = begin
process() = begin
    db = connect()
    # read JournalStatements
    bstm1 = create_statemnent("20200702", "Duck City Chronicals", "Invoice A1002", 1150, 1300, 2420.0, 0.0, 0.0, "LS")
    bstm2 = create_statemnent("20200703", "Donalds Hardware Store","Bill A1003", 1150, 1300, 1210.0, 0.0, 0.0, "LS")
    stms = [bstm1, bstm2]

    archive(db, "LEDGER", stms)

    return stms
end
