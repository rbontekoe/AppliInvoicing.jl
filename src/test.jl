# test.jl

#==
TEST WORKFLOW AppliInvoicing
==#

include("./infrastructure/infrastructure.jl")

#using Debugger

const PATH_DB = "./invoicing.sqlite"

const PATH_CSV = "./bank.csv"

# get orders
using AppliSales

# get orders
orders = AppliSales.process()
nn = 1000
invoices = [create(order, "A" * string(global nn += 1)) for order in orders]

# process orders
journal_entries_1 = process(PATH_DB, orders)

# get Bank statements and the unpaid invoices
stms = read_bank_statements(PATH_CSV)

unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)

# process the unpaid invoices and bank statements
journal_entries_2 = process(PATH_DB, unpaid_invoices, stms)
