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
