# IJulia
#
#
if Pkg.installed("IJulia") === nothing
    println("Installing IJulia...")
    Pkg.add("IJulia")
end

# Gadfly
# http://gadflyjl.org/
# Gadfly is a system for plotting and visualization based largely on Hadley Wickhams's ggplot2 for R, and Leland Wilkinson's book The Grammar of Graphics.
if Pkg.installed("Gadfly") === nothing
    println("Installing Gadfly...")
    Pkg.add("Gadfly")
    Pkg.add("Cairo")
end

# JuliaStats MultivariateStats
# https://github.com/JuliaStats/MultivariateStats.jl
# http://multivariatestatsjl.readthedocs.org/en/latest/index.html
# A Julia package for multivariate statistics and data analysis (e.g. dimension reduction)
if Pkg.installed("MultivariateStats") === nothing
    println("Installing MultivariateStats...")
    Pkg.add("MultivariateStats")
    Pkg.checkout("MultivariateStats")
end

# JLD
# https://github.com/JuliaLang/JLD.jl
# Saving and loading julia variables while preserving native types
if Pkg.installed("JLD") === nothing
    println("Installing JLD...")
    Pkg.add("JLD")
end

# JuMP
# http://www.juliaopt.org/
# http://jump.readthedocs.org/en/stable/
# Modeling language for Mathematical Programming (linear, mixed-integer, conic, nonlinear)
if Pkg.installed("JuMP") === nothing
    println("Installing JuMP...")
    Pkg.add("JuMP")
    Pkg.add("Cbc")
end

include("../src/clustering.jl")
const Clustering = Inf2912Clustering

println("Creating Datasets...")
import Clustering.create_large_dataset, Clustering.create_small_dataset

cd("notebook")

println("Large")
@time Clustering.create_large_dataset()
println("Small")
@time Clustering.create_small_dataset()

println("Creating Datasets done.")
