# runtests.jl

include("../src/infrastructure/infrastructure.jl")

using Test

using DataFrames

# TEST MODEL
@testset "Orders" begin
    using AppliSales
    orders = AppliSales.process()
    @test length(orders) == 3
    @test orders[1].org.name == "Scrooge Investment Bank"
    @test orders[1].training.name == "Learn Smiling"
end

@testset "UnpaidInvoices" begin
    invnbr = 1000
    path = "./test_invoicing.sqlite"
    db = connect(path)
    using AppliSales
    orders = AppliSales.process()
    invoices_to_save = [create(order, "A" * string(invnbr += 1)) for order in orders]
    archive(db, "UNPAID", invoices_to_save)
    invoices = retrieve_unpaid_invoices(path=path)
    #invoices = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame

    @test id(invoices[1]) == "A1001"
    @test currency_ratio(meta(invoices[1])) == 1.0
    @test name(header(invoices[1])) == "Scrooge Investment Bank"
    @test price_per_student(body(invoices[1])) == 1000.0
    @test length(students(body(invoices[1]))) == 1
    @test students(body(invoices[1]))[1] == "Scrooge McDuck"
    @test vat_perc(body(invoices[1])) == 0.21

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "Retrieve UnpaidInvoices" begin
    using AppliSales
    orders = AppliSales.process()
    process(orders)
    unpaid_invoices = retrieve_unpaid_invoices()

    @test id(unpaid_invoices[1]) == "A1001"
    @test currency_ratio(meta(unpaid_invoices[1])) == 1.0
    @test name(header(unpaid_invoices[1])) == "Scrooge Investment Bank"
    @test length(students(body(unpaid_invoices[1]))) == 1
    @test price_per_student(body(unpaid_invoices[1])) == 1000.0
    @test first(students(body(unpaid_invoices[1]))) == "Scrooge McDuck"
    @test vat_perc(body(unpaid_invoices[1])) == 0.21

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "Retrieve BankStatement from CSV" begin
    #stms = read_bank_statements("./bank.csv")
    stms = [BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)]
    @test length(stms) == 1
    #@test length(stms) == 2
    @test amount(stms[1]) == 2420.0
    #@test stms[2].amount == 1210.0
end

@testset "JounalEntry's" begin
    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]

    orders = AppliSales.process()
    process(orders)

    invoices = retrieve_unpaid_invoices()

    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for s in stms # get potential paid invoices
        if occursin(id(unpaid_invoice), descr(s)) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, s))
        end
      end
    end

    @test length(potential_paid_invoices) == 1
    @test id(potential_paid_invoices[1]) == "A1002"
    @test amount(stm((potential_paid_invoices[1]))) == 2420.0

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "process(db, orders)" begin
    orders = AppliSales.process()
    entries = process(orders)
    @test length(entries) == 3
    @test entries[1].from == 1300
    @test entries[1].to == 8000
    @test entries[1].debit == 1000.0
    @test entries[1].vat == 210.0
    @test entries[1].descr == "Learn Smiling"

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "retrieve_unpaid_invoices" begin
    path = "./test_invoicing.sqlite"
    orders = AppliSales.process()
    entries = process(orders; path=path)
    unpaid_invoices = retrieve_unpaid_invoices(path=path)

    @test length(unpaid_invoices) == 3
    @test id(unpaid_invoices[1]) == "A1001"

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "process(unpaid_invoices)" begin
    path = "./test_invoicing.sqlite"
    orders = AppliSales.process()
    process(orders, path=path)
    unpaid_invoices = retrieve_unpaid_invoices(path=path)

    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]
    entries = process(unpaid_invoices, stms; path=path)
    @test length(entries) == 1
    @test entries[1].from == 1150
    @test entries[1].to == 1300
    @test entries[1].debit == 2420.0

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "disconnect(db)" begin
    path = "./test_invoicing.sqlite"
    db = connect(path)
    orders = AppliSales.process()
    process(orders; path=path)
    disconnect(db)
    try
        retrieve(db, "UNPAID")
    catch e
        @test(typeof(e) == SQLite.SQLiteException)
    end

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end
