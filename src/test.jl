# test.jl

include("./infrastructure/infrastructure.jl")

# see: https://github.com/JuliaDebug/Debugger.jl
#using Debugger # use REPL for debugging

# activateing logging
# see: https://discourse.julialang.org/t/how-to-save-logging-output-to-a-log-file/14004/5
#using Logging
#io = open("log_invoicing.txt", "w+")
#logger = SimpleLogger(io)
#global_logger(logger)

@info("$(now()) - Test program started.")

const PATH_DB = "./invoicing.sqlite"

const PATH_CSV = "./bank.csv"

# get orders
orders = AppliSales.process()
@info("$(now()) - Orders received.");
invnbr = 1000
invoices = [create(order, "A" * string(global invnbr += 1)) for order in orders]
@info("$(now()) - Unpaid invoices created.")

# process orders
journal_entries_1 = process(PATH_DB, orders)
@info("$(now()) - Journal entries for unpaid invoices created.")

# get Bank statements and the unpaid invoices
stms = read_bank_statements(PATH_CSV)
@info("$(now()) - Get bankstatement entries for testing.")

unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)
@info("$(now()) - Unpaid invoices retrieved from database.")

# process the unpaid invoices and bank statements
journal_entries_2 = process(PATH_DB, unpaid_invoices, stms)
@info("$(now()) - Journal entries for paid invoices created.")

#flush(io) # needed when logging is enabled
#@info("Test program finished")

# cleanup
cmd = `rm ./invoicing.sqlite`
run(cmd)
