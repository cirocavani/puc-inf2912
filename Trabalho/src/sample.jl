include("dataset.jl")
include("io.jl")

export dataset_tiny,
    dataset_small,
    dataset_large,
    create_small_dataset,
    create_large_dataset

dataset_tiny() = Dataset(size=100, clusters=3, dimension=16, slot=3)

dataset_small() = Dataset(size=1000, clusters=3, dimension=200, slot=40)

dataset_large() = Dataset(size=10000, clusters=3, dimension=200, slot=40)

function save_small_dataset()
    export_dataset("small", dataset_small())
end

function save_large_dataset()
    export_dataset("large", dataset_large())
end
