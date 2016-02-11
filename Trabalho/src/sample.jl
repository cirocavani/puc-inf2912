include("dataset.jl")
include("io.jl")

export create_large_dataset, create_small_dataset

function create_large_dataset()
    dataset = Dataset(groups=3, size=1000, features=200, slot=40)
    export_dataset("large", dataset)
end

function create_small_dataset()
    dataset = Dataset(groups=3, size=100, features=200, slot=40)
    export_dataset("small", dataset)
end
