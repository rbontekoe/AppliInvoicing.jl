# runtests.jl

include("../src/infrastructure/infrastructure.jl")

using Test
using DataFrames
using AppliSQLite

const PATH_DB = "./invoicing.sqlite"
const PATH_CSV = "./bank.csv"

# TEST MODEL
@testset "Orders" begin
    using AppliSales
    orders = AppliSales.process()
    @test length(orders) == 3
    @test orders[1].org.name == "Scrooge Investment Bank"
    @test orders[1].training.name == "Learn Smiling"
end

@testset "UnpaidInvoices" begin
    db = connect(PATH_DB)
    using AppliSales
    orders = AppliSales.process()
    invoices = [create(order, "A" * string(1001)) for order in orders]
    @test invoices[1].id == "A1001"
    @test invoices[1].meta.currency_ratio == 1.0
    @test invoices[1].header.name == "Scrooge Investment Bank"
    @test invoices[1].body.price_per_student == 1000.0
    @test length(invoices[1].body.students) == 1
    @test invoices[1].body.students[1] == "Scrooge McDuck"
    @test invoices[1].body.vat_perc == 0.21
    stmt = `rm invoicing.sqlite`
    run(stmt)
end

@testset "Retrieve UnpaidInvoices" begin
    m = 1000

    db = connect(PATH_DB)
    using AppliSales
    orders = AppliSales.process()
    invoices_to_save = [create(order, "A" * string(m += 1)) for order in orders]
    archive(db, "UNPAID", invoices_to_save)
    unpaid_invoices = retrieve(db, "UNPAID") # returns dataframe
    invoices = [row[1] for row in eachrow(unpaid_invoices.item)] # dataframe to array

    @test invoices[1].id == "A1001"
    @test invoices[1].meta.currency_ratio == 1.0
    @test invoices[1].header.name == "Scrooge Investment Bank"
    @test length(invoices[1].body.students) == 1
    @test invoices[1].body.price_per_student == 1000.0
    @test invoices[1].body.students[1] == "Scrooge McDuck"
    @test invoices[1].body.vat_perc == 0.21
    stmt = `rm invoicing.sqlite`
    run(stmt)
end

@testset "JounalEntry's" begin
    stm1 = BankStatement(Date(2020-01-15), "Duck City Chronicals Invoice A1002", "NL93INGB", 2420.0)
    stms = [stm1]

    m = 1000

    db = connect(PATH_DB)
    using AppliSales
    orders = AppliSales.process()
    invoices_to_save = [create(order, "A" * string(m += 1)) for order in orders]
    archive(db, "UNPAID", invoices_to_save)
    unpaid_invoices = retrieve(db, "UNPAID")
    invoices = [row[1] for row in eachrow(unpaid_invoices.item)]

    potential_paid_invoices = []
    for unpaid_invoice in invoices
      for stm in stms # get potential paid invoices
        if occursin(unpaid_invoice.id, stm.descr) # description contains invoice number
          push!(potential_paid_invoices, create(unpaid_invoice, stm))
        end
      end
    end

    #r = [filter(x -> occursin(x.id, stm.descr), invoices) for stm in stms]

    paid_invoices = convert(Array{PaidInvoice, 1}, potential_paid_invoices)
    #paid_invoices = convert(Array{PaidInvoice, 1}, r)

    @test length(paid_invoices) == 1
    stmt = `rm invoicing.sqlite`
    run(stmt)
end
