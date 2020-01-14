#include("./api/api.jl")

include("./infrastructure/infrastructure.jl")

using AppliSales

invoices = AppliSales.process()

result = process(invoices)

using AppliGeneralLegder

result2 = process()
