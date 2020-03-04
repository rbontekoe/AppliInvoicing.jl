# doc.jl - infrastructure

"""
    process(path::String, ::Array{AppliSales.Order, 1})

    process(path::String, ::Array{UnpaidInvoice, 1}, ::Array{AppliGeneralLedger.BankStatement, 1})

- Creates UnpaidInvoice's from AppliSale.Order's, archive them, and creates AppliGeneralLedger.Entry's for the general ledger.
- Creates PaidInvoices's from UnpaidInvoices by using AppliGeneralLedger.BankStatement's, and creates AppliGeneralLedger.Entry's for the general ledger.

# Example

```
julia> using AppliSales

julia> using AppliGeneralLedger

julia> using AppliInvoicing

julia> const PATH_DB = "./test_invoicing.sqlite"

julia> const PATH_CSV = "./bank.csv"

julia> orders = AppliSales.process()

julia> journal_entries_1 = AppliInvoicing.process(PATH_DB, orders)

julia> stms = AppliInvoicing.read_bank_statements(PATH_CSV)

julia> unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)

julia> journal_entries_2 = AppliInvoicing.process(PATH_DB, unpaid_invoices, stms)

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```
"""
function process end


"""
    read_bank_statements(path::String)

Retrieves bank statements from a CSV-file.

# Example

```
julia> const PATH_CSV = "./bank.csv"

julia> stms = AppliInvoicing.read_bank_statements(PATH_CSV)
```
"""
function read_bank_statements end


"""
    retrieve_unpaid_invoices(path::String)::Array{UnpaidInvoice, 1}

Retrieves UnpaidInvoice's from a SQLite.jl database.

# Example

```
julia> using AppliSales

julia> using AppliInvoicing

julia> const PATH_DB = "./test_invoicing.sqlite"

julia> orders = AppliSales.process()

julia> AppliInvoicing.process(PATH_DB, orders)

julia> unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)

julia> cmd = `rm test_invoicing.sqlite`

julia> run(cmd)
```
"""
function retrieve_unpaid_invoices end
