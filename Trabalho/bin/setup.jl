Pkg.update()

# IJulia
# https://github.com/JuliaLang/IJulia.jl
# IJulia is a Julia-language backend combined with the Jupyter interactive environment.
println("Installing IJulia...")
Pkg.add("IJulia")

# Gadfly
# http://gadflyjl.org/
# Gadfly is a system for plotting and visualization based largely on Hadley Wickhams's ggplot2 for R, and Leland Wilkinson's book The Grammar of Graphics.
println("Installing Gadfly...")
Pkg.add("Gadfly")
Pkg.add("Cairo")

# JuliaStats MultivariateStats
# https://github.com/JuliaStats/MultivariateStats.jl
# http://multivariatestatsjl.readthedocs.org/en/latest/index.html
# A Julia package for multivariate statistics and data analysis (e.g. dimension reduction)
println("Installing MultivariateStats...")
Pkg.add("MultivariateStats")
Pkg.checkout("MultivariateStats")

# JLD
# https://github.com/JuliaLang/JLD.jl
# Saving and loading julia variables while preserving native types
println("Installing JLD...")
Pkg.add("JLD")

# JuMP
# http://www.juliaopt.org/
# http://jump.readthedocs.org/en/stable/
# Modeling language for Mathematical Programming (linear, mixed-integer, conic, nonlinear)
println("Installing JuMP...")
Pkg.add("JuMP")
Pkg.add("Cbc")

include("../src/clustering.jl")
const Clustering = Inf2912Clustering

println("Creating Datasets...")
import Clustering.save_large_dataset, Clustering.save_small_dataset

println("Large")
@time Clustering.save_large_dataset()
println("Small")
@time Clustering.save_small_dataset()

println("Creating Datasets done.")
