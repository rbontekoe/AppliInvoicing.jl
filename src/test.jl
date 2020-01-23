# test.jl

#==
TEST WORKFLOW AppliInvoicing
==#

include("./infrastructure/infrastructure.jl")

#using Debugger

const PATH_DB = "./invoicing.sqlite"

const PATH_CSV = "./bank.csv"

# get orders
orders = AppliSales.process()
nn = 1000
invoices = [create(order, "A" * string(global nn += 1)) for order in orders]

db = connect(PATH_DB)

# process orders
journal_entries_1 = process(db, orders)

# get Bank statements and the unpaid invoices
stms = read_bank_statements(PATH_CSV)

unpaid_invoices = retrieve_unpaid_invoices(db)

# process the unpaid invoices and bank statements
journal_entries_2 = process(db, unpaid_invoices, stms)

cmd = `rm ./invoicing.sqlite`

run(cmd)
