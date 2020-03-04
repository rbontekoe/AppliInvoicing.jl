# Example

## Example -  user

```julia
julia> using AppliSales

julia> using AppliInvoicing

julia> using AppliGeneralLedger

julia> using DataFrames

julia> using CSV

julia> using SQLite

julia> const PATH_DB = "./test_invoicing.sqlite"
"./test_invoicing.sqlite"

julia> const PATH_CSV = "./bank.csv"
"./bank.csv"

julia> # get orders
       orders = AppliSales.process()
3-element Array{AppliSales.Order,1}:
 AppliSales.Order("2438091263718968922", AppliSales.Organization("3427371109961104901", "Scrooge Investment Bank", "1180 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA"), AppliSales.Training("LS", 2019-08-30T00:00:00, 2, "Learn Smiling", 1000.0), "PO-456", "Scrooge McDuck", "scrooge@duckcity.com", ["Scrooge McDuck"])
 AppliSales.Order("1138078377637347262", AppliSales.Organization("3868942126239046229", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA"), AppliSales.Training("LS", 2019-08-30T00:00:00, 2, "Learn Smiling", 1000.0), "DD-001", "Mickey Mouse", "mickey@duckcity.com", ["Mini Mouse", "Goofy"])
 AppliSales.Order("12370498358369136371", AppliSales.Organization("2768094194732922249", "Donalds Hardware Store", "1190 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA"), AppliSales.Training("LS", 2019-08-30T00:00:00, 2, "Learn Smiling", 1000.0), "", "Donald Duck", "donald@duckcity.com", ["Daisy Duck"])              

julia> journal_entries_1 = AppliInvoicing.process(PATH_DB, orders)
3-element Array{AppliGeneralLedger.JournalEntry,1}:
 AppliGeneralLedger.JournalEntry("2020-03-04-1", 3, 2020-03-04T11:15:04.628, "Scrooge Investment Bank", "A1001", 1300, 8000, 1000.0, 0.0, 210.0, "Learn Smiling")
 AppliGeneralLedger.JournalEntry("2020-03-04-2", 3, 2020-03-04T11:15:04.628, "Duck City Chronicals", "A1002", 1300, 8000, 2000.0, 0.0, 420.0, "Learn Smiling")   
 AppliGeneralLedger.JournalEntry("2020-03-04-3", 3, 2020-03-04T11:15:04.628, "Donalds Hardware Store", "A1003", 1300, 8000, 1000.0, 0.0, 210.0, "Learn Smiling")

julia> # get Bank statemnets and unpaid invoices
       stms = AppliInvoicing.read_bank_statements(PATH_CSV)
2-element Array{AppliInvoicing.BankStatement,1}:
 AppliInvoicing.BankStatement(2020-01-15, "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
 AppliInvoicing.BankStatement(2020-01-15, "Donalds Hardware Store Bill A1003", "NL39INGB", 1210.0)

julia> unpaid_invoices = retrieve_unpaid_invoices(PATH_DB)
3-element Array{AppliInvoicing.UnpaidInvoice,1}:
 AppliInvoicing.UnpaidInvoice("A1001", AppliInvoicing.MetaInvoice("2438091263718968922", "LS", 2020-03-04T11:15:02.978, "€", 1.0), AppliInvoicing.Header("A1001", "Scrooge Investment Bank", "1180 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "PO-456", "Scrooge McDuck", "scrooge@duckcity.com"), AppliInvoicing.OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Scrooge McDuck"], 0.21))
 AppliInvoicing.UnpaidInvoice("A1002", AppliInvoicing.MetaInvoice("1138078377637347262", "LS", 2020-03-04T11:15:02.978, "€", 1.0), AppliInvoicing.Header("A1002", "Duck City Chronicals", "1185 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "DD-001", "Mickey Mouse", "mickey@duckcity.com"), AppliInvoicing.OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Mini Mouse", "Goofy"], 0.21))
 AppliInvoicing.UnpaidInvoice("A1003", AppliInvoicing.MetaInvoice("12370498358369136371", "LS", 2020-03-04T11:15:02.978, "€", 1.0), AppliInvoicing.Header("A1003", "Donalds Hardware Store", "1190 Seven Seas Dr", "FL 32830", "Lake Buena Vista", "USA", "", "Donald Duck", "donald@duckcity.com"), AppliInvoicing.OpentrainingItem("Learn Smiling", 2019-08-30T00:00:00, 1000.0, ["Daisy Duck"], 0.21))              

julia> # process unpaid invoices and bank staements
       journal_entries_2 = AppliInvoicing.process(PATH_DB, unpaid_invoices, stms)
2-element Array{AppliGeneralLedger.JournalEntry,1}:
 AppliGeneralLedger.JournalEntry("2020-03-04-4", 3, 2020-03-04T11:15:12.968, "Duck City Chronicals", "A1002", 1150, 1300, 2420.0, 0.0, 0.0, "Learn Smiling")  
 AppliGeneralLedger.JournalEntry("2020-03-04-5", 3, 2020-03-04T11:15:12.968, "Donalds Hardware Store", "A1003", 1150, 1300, 1210.0, 0.0, 0.0, "Learn Smiling")

julia> # =============================

       # process journal entries
       const PATH_DB_LEDGER = "./test_ledger.txt"
"./test_ledger.txt"

julia> const PATH_DB_JOURNAL = "./test_journal.txt"
"./test_journal.txt"

julia> AppliGeneralLedger.process(PATH_DB_JOURNAL, PATH_DB_LEDGER, journal_entries_1)

julia> # process journal entries

       AppliGeneralLedger.process(PATH_DB_JOURNAL, PATH_DB_LEDGER, journal_entries_2)

julia> # read all general ledger accounts
       r = AppliGeneralLedger.read_from_file(PATH_DB_LEDGER)
13-element Array{Any,1}:
 AppliGeneralLedger.Record("2020-03-04-1", 1300, 2020-03-04T11:15:04.628, "Scrooge Investment Bank", "A1001", 1210.0, 0.0, "Learn Smiling")
 AppliGeneralLedger.Record("2020-03-04-1", 8000, 2020-03-04T11:15:04.628, "Scrooge Investment Bank", "A1001", 0.0, 1000.0, "Learn Smiling")
 AppliGeneralLedger.Record("2020-03-04-1", 4000, 2020-03-04T11:15:04.628, "Scrooge Investment Bank", "A1001", 0.0, 210.0, "Learn Smiling")
 AppliGeneralLedger.Record("2020-03-04-2", 1300, 2020-03-04T11:15:04.628, "Duck City Chronicals", "A1002", 2420.0, 0.0, "Learn Smiling")   
 AppliGeneralLedger.Record("2020-03-04-2", 8000, 2020-03-04T11:15:04.628, "Duck City Chronicals", "A1002", 0.0, 2000.0, "Learn Smiling")   
 ⋮                                                                                                                                         
 AppliGeneralLedger.Record("2020-03-04-4", 1150, 2020-03-04T11:15:12.968, "Duck City Chronicals", "A1002", 2420.0, 0.0, "Learn Smiling")   
 AppliGeneralLedger.Record("2020-03-04-4", 1300, 2020-03-04T11:15:12.968, "Duck City Chronicals", "A1002", 0.0, 2420.0, "Learn Smiling")   
 AppliGeneralLedger.Record("2020-03-04-5", 1150, 2020-03-04T11:15:12.968, "Donalds Hardware Store", "A1003", 1210.0, 0.0, "Learn Smiling")
 AppliGeneralLedger.Record("2020-03-04-5", 1300, 2020-03-04T11:15:12.968, "Donalds Hardware Store", "A1003", 0.0, 1210.0, "Learn Smiling")

julia> df = DataFrame(r)
13×8 DataFrame. Omitted printing of 1 columns
│ Row │ id           │ accountid │ date                    │ customerid              │ invoice_nbr │ debit   │ credit  │
│     │ String       │ Int64     │ Dates.DateTime          │ String                  │ String      │ Float64 │ Float64 │
├─────┼──────────────┼───────────┼─────────────────────────┼─────────────────────────┼─────────────┼─────────┼─────────┤
│ 1   │ 2020-03-04-1 │ 1300      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 1210.0  │ 0.0     │
│ 2   │ 2020-03-04-1 │ 8000      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 0.0     │ 1000.0  │
⋮
│ 11  │ 2020-03-04-4 │ 1300      │ 2020-03-04T11:15:12.968 │ Duck City Chronicals    │ A1002       │ 0.0     │ 2420.0  │
│ 12  │ 2020-03-04-5 │ 1150      │ 2020-03-04T11:15:12.968 │ Donalds Hardware Store  │ A1003       │ 1210.0  │ 0.0     │
│ 13  │ 2020-03-04-5 │ 1300      │ 2020-03-04T11:15:12.968 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 1210.0  │

julia> println(df)
13×8 DataFrame
│ Row │ id           │ accountid │ date                    │ customerid              │ invoice_nbr │ debit   │ credit  │ descr         │
│     │ String       │ Int64     │ Dates.DateTime          │ String                  │ String      │ Float64 │ Float64 │ String        │
├─────┼──────────────┼───────────┼─────────────────────────┼─────────────────────────┼─────────────┼─────────┼─────────┼───────────────┤
│ 1   │ 2020-03-04-1 │ 1300      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 1210.0  │ 0.0     │ Learn Smiling │
│ 2   │ 2020-03-04-1 │ 8000      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 0.0     │ 1000.0  │ Learn Smiling │
│ 3   │ 2020-03-04-1 │ 4000      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 0.0     │ 210.0   │ Learn Smiling │
│ 4   │ 2020-03-04-2 │ 1300      │ 2020-03-04T11:15:04.628 │ Duck City Chronicals    │ A1002       │ 2420.0  │ 0.0     │ Learn Smiling │
│ 5   │ 2020-03-04-2 │ 8000      │ 2020-03-04T11:15:04.628 │ Duck City Chronicals    │ A1002       │ 0.0     │ 2000.0  │ Learn Smiling │
│ 6   │ 2020-03-04-2 │ 4000      │ 2020-03-04T11:15:04.628 │ Duck City Chronicals    │ A1002       │ 0.0     │ 420.0   │ Learn Smiling │
│ 7   │ 2020-03-04-3 │ 1300      │ 2020-03-04T11:15:04.628 │ Donalds Hardware Store  │ A1003       │ 1210.0  │ 0.0     │ Learn Smiling │
│ 8   │ 2020-03-04-3 │ 8000      │ 2020-03-04T11:15:04.628 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 1000.0  │ Learn Smiling │
│ 9   │ 2020-03-04-3 │ 4000      │ 2020-03-04T11:15:04.628 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 210.0   │ Learn Smiling │
│ 10  │ 2020-03-04-4 │ 1150      │ 2020-03-04T11:15:12.968 │ Duck City Chronicals    │ A1002       │ 2420.0  │ 0.0     │ Learn Smiling │
│ 11  │ 2020-03-04-4 │ 1300      │ 2020-03-04T11:15:12.968 │ Duck City Chronicals    │ A1002       │ 0.0     │ 2420.0  │ Learn Smiling │
│ 12  │ 2020-03-04-5 │ 1150      │ 2020-03-04T11:15:12.968 │ Donalds Hardware Store  │ A1003       │ 1210.0  │ 0.0     │ Learn Smiling │
│ 13  │ 2020-03-04-5 │ 1300      │ 2020-03-04T11:15:12.968 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 1210.0  │ Learn Smiling │

julia> df2 = df[df.accountid .== 1300, :]
5×8 DataFrame. Omitted printing of 1 columns
│ Row │ id           │ accountid │ date                    │ customerid              │ invoice_nbr │ debit   │ credit  │
│     │ String       │ Int64     │ Dates.DateTime          │ String                  │ String      │ Float64 │ Float64 │
├─────┼──────────────┼───────────┼─────────────────────────┼─────────────────────────┼─────────────┼─────────┼─────────┤
│ 1   │ 2020-03-04-1 │ 1300      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 1210.0  │ 0.0     │
│ 2   │ 2020-03-04-2 │ 1300      │ 2020-03-04T11:15:04.628 │ Duck City Chronicals    │ A1002       │ 2420.0  │ 0.0     │
│ 3   │ 2020-03-04-3 │ 1300      │ 2020-03-04T11:15:04.628 │ Donalds Hardware Store  │ A1003       │ 1210.0  │ 0.0     │
│ 4   │ 2020-03-04-4 │ 1300      │ 2020-03-04T11:15:12.968 │ Duck City Chronicals    │ A1002       │ 0.0     │ 2420.0  │
│ 5   │ 2020-03-04-5 │ 1300      │ 2020-03-04T11:15:12.968 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 1210.0  │

julia> account_receivable = sum(df2.debit - df2.credit)
1210.0

julia> @info("Balance of accounts receivable is $(account_receivable). Should be 1210")
[ Info: Balance of accounts receivable is 1210.0. Should be 1210

julia> println("Status accounts receivable: € $account_receivable") # should be € 1210.0
Status accounts receivable: € 1210.0

julia> # get status of sales
       df2 = df[df.accountid .== 8000, :]
3×8 DataFrame. Omitted printing of 1 columns
│ Row │ id           │ accountid │ date                    │ customerid              │ invoice_nbr │ debit   │ credit  │
│     │ String       │ Int64     │ Dates.DateTime          │ String                  │ String      │ Float64 │ Float64 │
├─────┼──────────────┼───────────┼─────────────────────────┼─────────────────────────┼─────────────┼─────────┼─────────┤
│ 1   │ 2020-03-04-1 │ 8000      │ 2020-03-04T11:15:04.628 │ Scrooge Investment Bank │ A1001       │ 0.0     │ 1000.0  │
│ 2   │ 2020-03-04-2 │ 8000      │ 2020-03-04T11:15:04.628 │ Duck City Chronicals    │ A1002       │ 0.0     │ 2000.0  │
│ 3   │ 2020-03-04-3 │ 8000      │ 2020-03-04T11:15:04.628 │ Donalds Hardware Store  │ A1003       │ 0.0     │ 1000.0  │

julia> sales = sum(df2.credit - df2.debit) # should return € 4000.0
4000.0

julia> @info("Sales is $(sales). Should be 4000.")
[ Info: Sales is 4000.0. Should be 4000.

julia> println("Sales: € $sales")
Sales: € 4000.0

julia> # cleanup
       stm = `rm test_invoicing.sqlite test_ledger.txt test_journal.txt`
`rm test_invoicing.sqlite test_ledger.txt test_journal.txt`

julia> run(stm)
Process(`rm test_invoicing.sqlite test_ledger.txt test_journal.txt`, ProcessExited(0))
```
