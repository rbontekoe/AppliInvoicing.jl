# runtests.jl

include("../src/infrastructure/infrastructure.jl")

using Test

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
    invoices = retrieve_unpaid_invoices(path)
    #invoices = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame

    @test invoices[1].id == "A1001"
    @test invoices[1].meta.currency_ratio == 1.0
    @test invoices[1].header.name == "Scrooge Investment Bank"
    @test invoices[1].body.price_per_student == 1000.0
    @test length(invoices[1].body.students) == 1
    @test invoices[1].body.students[1] == "Scrooge McDuck"
    @test invoices[1].body.vat_perc == 0.21

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "Retrieve UnpaidInvoices" begin
    invnbr = 1000
    path = "./test_invoicing.sqlite"
    db = connect(path)
    using AppliSales
    orders = AppliSales.process()
    invoices_to_save = [create(order, "A" * string(invnbr += 1)) for order in orders]
    archive(db, "UNPAID", invoices_to_save)
    #unpaid_invoices = retrieve(db, "UNPAID") # returns dataframe
    unpaid_invoices = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame
    invoices = [row[1] for row in eachrow(unpaid_invoices.item)] # dataframe to array

    @test invoices[1].id == "A1001"
    @test invoices[1].meta.currency_ratio == 1.0
    @test invoices[1].header.name == "Scrooge Investment Bank"
    @test length(invoices[1].body.students) == 1
    @test invoices[1].body.price_per_student == 1000.0
    @test invoices[1].body.students[1] == "Scrooge McDuck"
    @test invoices[1].body.vat_perc == 0.21

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "Retrieve BankStatement from CSV" begin
    #stms = read_bank_statements("./bank.csv")
    stms = [BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)]
    @test length(stms) == 1
    #@test length(stms) == 2
    @test stms[1].amount == 2420.0
    #@test stms[2].amount == 1210.0
end

@testset "JounalEntry's" begin
    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]

    invnbr = 1000

    path = "./test_invoicing.sqlite"
    db = connect(path)
    #using AppliSales
    orders = AppliSales.process()
    invoices_to_save = [create(order, "A" * string(invnbr += 1)) for order in orders]
    archive(db, "UNPAID", invoices_to_save)
    #unpaid_invoices = retrieve(db, "UNPAID")
    unpaid_invoices = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame
    invoices = unpaid_invoices.item

    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for stm in stms # get potential paid invoices
        if occursin(unpaid_invoice.id, stm.descr) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, stm))
        end
      end
    end

    @test length(potential_paid_invoices) == 1
    @test potential_paid_invoices[1].id == "A1002"
    @test potential_paid_invoices[1].stm.amount == 2420.0

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "process(db, orders)" begin
    path = "./test_invoicing.sqlite"
    db = connect(path)
    orders = AppliSales.process()
    entries = process(path, orders)
    @test length(entries) == 3
    @test entries[1].from == 1300
    @test entries[1].to == 8000
    @test entries[1].debit == 1000.0
    @test entries[1].vat == 210.0
    @test entries[1].descr == "Learn Smiling"

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

#@testset "retrieve_unpaid_invoices(db)" begin
@testset "retrieve_unpaid_invoices" begin
    path = "./test_invoicing.sqlite"
    db = connect(path)
    orders = AppliSales.process()
    entries = process(path, orders)
    unpaid_invoices = retrieve_unpaid_invoices(path)
    #unpaid_invoices = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame
    @test length(unpaid_invoices) == 3
    @test unpaid_invoices[1].id == "A1001"

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end

@testset "process(db, unpaid_invoices)" begin
    path = "./test_invoicing.sqlite"
    db = connect(path)
    orders = AppliSales.process()
    process(path, orders)
    unpaid_invoices = retrieve_unpaid_invoices(path)
    #result = SQLite.DBInterface.execute(db, "select * from UNPAID") |> DataFrame
    #unpaid_invoices = result.item
    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]
    entries = process(path, unpaid_invoices, stms)
    @test length(entries) == 1
    @test entries[1].from == 1150
    @test entries[1].to == 1300
    @test entries[1].debit == 2420.0

    cmd = `rm test_invoicing.sqlite`
    run(cmd)
end
