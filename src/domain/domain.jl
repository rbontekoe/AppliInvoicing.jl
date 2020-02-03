using Dates
using SQLite
using DataFrames
using CSV
using AppliGeneralLedger
using AppliSales # needed for test.jl and runtests.jl

struct MetaInvoice
    order_id::String
    training_id::String
    date::DateTime
    currency::String
    currency_ratio::Float64
    # Constructors
    MetaInvoice(order_id, training_id) = new(order_id, training_id, now(), "€", 1.0) #2
    MetaInvoice(order_id, training_id, date, currency, currency_ratio) = new(order_id, training_id, now(), currency, currency_ratio)
end # MetaInvoice

struct Header
    invoice_nbr::String
    name::String
    address::String
    zip::String
    city::String
    country::String
    order_ref::String
    name_contact::String
    email_contact::String
end # Header

struct OpentrainingItem
    name_training::String
    date::DateTime
    price_per_student::Float64
    students::Array{String, 1}
    vat_perc::Float64
    # constructors
    OpentrainingItem(name_training, date, price_per_student, students) = new(name_training, date, price_per_student, students, 0.21)
    OpentrainingItem(name_training, date, price_per_student, students, vat_perc) = new(name_training, date, price_per_student, students, vat_perc)
end # OpentrainingItem

struct UnpaidInvoice
    id::String
    meta::MetaInvoice
    header::Header
    body::OpentrainingItem
end # UnpaidInvoice

struct BankStatement
	date::Date
	descr::String
	iban::String
	amount::Float64
end # BankStatement

struct PaidInvoice
    id::String
    meta::MetaInvoice
    header::Header
    body::OpentrainingItem
    stm::BankStatement
end # PaidInvoice
