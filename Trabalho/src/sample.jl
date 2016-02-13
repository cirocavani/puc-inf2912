include("dataset.jl")
include("io.jl")

export dataset_tiny,
    dataset_small,
    dataset_large,
    create_small_dataset,
    create_large_dataset

dataset_tiny() = Dataset(size=100, groups=3, features=16, slot=3)

dataset_small() = Dataset(groups=3, size=1000, features=200, slot=40)

dataset_large() = Dataset(groups=3, size=10000, features=200, slot=40)

function save_small_dataset()
    export_dataset("small", dataset_small())
end

function save_large_dataset()
    export_dataset("large", dataset_large())
end
