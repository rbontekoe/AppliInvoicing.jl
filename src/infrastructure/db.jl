# db.jl

# Database item
struct DatabaseItem{T}
   time::Float64
   agent::String
   action::String
   key::String
   item::T
end # DatabaseItem

# createDatabaseItem - internal function
const agent = "AB9F"
createDatabaseItem(item::Any; agent=agent, action="CREATE") = DatabaseItem(time(), agent, action, item.id, item)

# Connect with PATH_CSV
connect(path::String)::SQLite.DB = SQLite.DB(path)

# connect to in-memory database
connect()::SQLite.DB = SQLite.DB()

# archive an item as DatabaseItem
archive(db, table::String, items::Array{T, 1} where {T <: Any}) = begin
   # save items
   dbi = [ createDatabaseItem( i ; action="CREATE" ) for i in items]
   # return as dataframe
   DataFrame( dbi ) |> SQLite.load!(db, table)
end # archive

#store the fields of an item
store(db, table::String, items::Array{T, 1} where {T <: Any}) = begin
   DataFrame( items ) |> SQLite.load!(db, table)
end # store

# retrieve all item from a table
retrieve(db, table::String)::DataFrame = SQLite.Query( db, "select * from $table") |> DataFrame

# retrieve item form a table based on a sql condition
retrieve(db, table::String, condition::String )::DataFrame = SQLite.Query( db, "select * from $table where $condition")  |> DataFrame

# run a custom function
runfunct(funct, x, y, z) = funct(x, y, z)
