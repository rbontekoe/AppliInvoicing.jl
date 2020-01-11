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

process(orders::Array{Order, 1}) = begin
    db = connect()
    # get last order number
    n = 1000
    # create invoices
    invoices = [create(order, "A" * string(n += 1)) for order in orders]
    # archive invoices
    archive(db, string(UNPAID), invoices)
    # get invoices
    retrieve(db, string(UNPAID))
    # send invoices

    # create journal statements

end
