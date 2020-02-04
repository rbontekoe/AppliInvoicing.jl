#  print_invoice.jl

# Example code to print invoices

# print header

using Printf # package for formatting numbers

include("./infrastructure/infrastructure.jl")

function show_invoice(invoice::UnpaidInvoice)
    basic(invoice)
    println("="^60)
    println()
end

#==
function show_invoice(invoice::PaidInvoice)
    println("P A I D  $symbol$(@sprintf("%.2f", invoice.entry.amount))") : println("U N P A I D")
    println("="^60)
    println()
end
==#

function basic(invoice)
    println(invoice.header.name)
    println("Attn. $(invoice.header.name_contact)")
    println("$(invoice.header.address) ")
    print("$(invoice.header.city), ")
    println("$(invoice.header.zip)")
    println("$(invoice.header.country)")
    println()
    #print("INVOICE")
    #println("Date: $(Date(inv.date))")
    println("Invoice number: $(invoice.header.invoice_nbr)")
    println("="^40)
    println("Reference: $(invoice.header.order_ref) - $(string(Date(invoice.body.date)))")
    println()
    println("Training: $(invoice.body.name_training) - $(string(Date(invoice.body.date)))")
    println()
    nbr_students = length(invoice.body.students)
    unitprice = round(invoice.body.price_per_student * invoice.meta.currency_ratio; digits=2)
    price = round(nbr_students * unitprice; digits=2)
    vat = round(price*invoice.body.vat_perc; digits=2)
    totalprice = round(price + vat; digits=2)
    symbol = invoice.meta.currency

    println("#     Price                        Total")
    println("="^40)
    println("$nbr_students     $(@sprintf("%.2f", unitprice))                   $symbol$(@sprintf("%.2f", price))")
    println()
    println("STUDENT(S)")
    println("-"^20)
    for name in invoice.body.students
        println(name)
    end
    println()
    println("VAT                              $symbol$(@sprintf("%.2f", vat))")
    println("="^40)
    println("Total price                     $symbol$(@sprintf("%.2f", totalprice))")
    println()
end
