using Dates
using AppliGeneralLedger
using AppliSales # needed for test.jl and runtests.jl

include("./spec.jl")

struct MetaInvoice <: Structure
    order_id::String
    training_id::String
    date::DateTime
    currency::String
    currency_ratio::Float64
    # Constructors
    MetaInvoice(order_id, training_id) = new(order_id, training_id, now(), "€", 1.0) #2
    MetaInvoice(order_id, training_id, date, currency, currency_ratio) = new(order_id, training_id, now(), currency, currency_ratio)
end # MetaInvoice

struct Header <: Structure
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

struct OpentrainingItem <: BodyItem
    name_training::String
    date::DateTime
    price_per_student::Float64
    students::Array{String, 1}
    vat_perc::Float64
    # constructors
    OpentrainingItem(name_training, date, price_per_student, students) = new(name_training, date, price_per_student, students, 0.21)
    OpentrainingItem(name_training, date, price_per_student, students, vat_perc) = new(name_training, date, price_per_student, students, vat_perc)
end # OpentrainingItem

struct UnpaidInvoice <: Invoice
    _id::String
    _meta::MetaInvoice
    _header::Header
    _body::OpentrainingItem
end # UnpaidInvoice

struct BankStatement <: Payment
	date::Date
	descr::String
	iban::String
	amount::Float64
end # BankStatement

struct PaidInvoice <: Invoice
    _id::String
    _meta::MetaInvoice
    _header::Header
    _body::OpentrainingItem
    _stm::BankStatement
end # PaidInvoice

"""
    stm(i::PaidInvoice)

Returns the Bankstatement of a paid invoice.
"""
stm(i::PaidInvoice) = i._stm

# Fields Invoice
meta(i::Invoice)::MetaInvoice = i._meta
header(i::Invoice)::Header = i._header
body(i::Invoice)::BodyItem = i._body
id(i::Invoice)::String = i._id

# fields MetaInvoice
order_id(m::MetaInvoice)::String = m.order_id
training_id(m::MetaInvoice)::String = m.training_id
date(m::MetaInvoice)::DateTime = m.date
currency(m::MetaInvoice)::String = m.currency
currency_ratio(m::MetaInvoice)::Float64 = m.currency_ratio

# fields Header
invoice_nbr(h::Header)::String = h.invoice_nbr
name(h::Header)::String = h.name
address(h::Header)::String = h.address
zip(h::Header)::String = h.zip
city(h::Header)::String = h.city
country(h::Header)::String = h.country
order_ref(h::Header)::String = h.order_ref
name_contact(h::Header)::String = h.name_contact
email_contact(h::Header)::String = h.email_contact

# field OpenTraining
name_training(o::OpentrainingItem)::String = o.name_training
date(o::OpentrainingItem)::DateTime = o.date
price_per_student(o::OpentrainingItem)::Float64 = o.price_per_student
students(o::OpentrainingItem)::Array{String, 1} = o.students
vat_perc(o::OpentrainingItem)::Float64 = o.vat_perc

# gfields BankStatement
date(b::BankStatement)::Date = b.date
descr(b::BankStatement)::String = b.descr
iban(b::BankStatement)::String = b.iban
amount(b::BankStatement)::Float64 = b.amount
