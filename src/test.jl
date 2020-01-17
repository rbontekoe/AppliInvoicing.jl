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

# process orders
journal_entries_1 = process(PATH_DB, orders)

# get Bank statemnets and unpaid invoices
stms = read_bank_statements(PATH_CSV)

unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)

# process unpaid invoices and bank staements
journal_entries_2 = process(PATH, unpaid_invoices, stms)
