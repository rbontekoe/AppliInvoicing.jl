include("./infrastructure/infrastructure.jl")

using CSV

# get orders

using AppliSales

# get orders

orders = AppliSales.process()

# process orders

journal_entries_1 = process(orders)

# get Bank statemnets

stms = read_bank_statements()

# process bank staements

journal_entries_2 = process(stms)
