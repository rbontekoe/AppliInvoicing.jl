# test.jl

include("./infrastructure/infrastructure.jl")

using DataFrames
# see: https://github.com/JuliaDebug/Debugger.jl
#using Debugger # use REPL for debugging

# activating logging
# see: https://discourse.julialang.org/t/how-to-save-logging-output-to-a-log-file/14004/5
#using Logging
#io = open("log_invoicing.txt", "w+")
#logger = SimpleLogger(io)
#global_logger(logger)

@info("$(now()) - Test program started.")

const PATH_CSV = "./bank.csv"

# get orders
orders = AppliSales.process()
@info("$(now()) - Orders received.");
invnbr = 1000
invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]
@info("$(now()) - Unpaid invoices created.")

# first invoice
invoice_1 = invoices[1]

# meta data
@info("$(now())", meta(invoice_1))

# header
@info("$(now())", header(invoice_1))

# body
@info("$(now())", body(invoice_1))

# id
@info("$(now())", id(invoice_1))

# process orders
journal_entries_1 = process(orders)
@info("$(now()) - Journal entries for unpaid invoices created.")

# get Bank statements and the unpaid invoices
stms = read_bank_statements(PATH_CSV)
@info("$(now()) - Get bankstatement entries for testing.")

unpaid_invoices = retrieve_unpaid_invoices()
@info("$(now()) - Unpaid invoices retrieved from database.")

# process the unpaid invoices and bank statements
journal_entries_2 = process(unpaid_invoices, stms)
@info("$(now()) - Journal entries for paid invoices created.")

paid_invoices = retrieve_paid_invoices()
@info("$(now()) - Paid invoices retrieved from database.")
#flush(io) # needed when logging is enabled
#@info("Test program finished")

# print an invoice example
#include("./print_invoice.jl")
#invoices = retrieve_unpaid_invoices(PATH_DB_TEST)
#basic(invoices[2])

# cleanup
cmd = `rm ./test_invoicing.sqlite`
run(cmd)

@info("$(now()) - databaseT removed")
