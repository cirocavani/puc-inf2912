include("dataset.jl")
include("baseline.jl")
include("evaluation.jl")
include("visualization.jl")

export export_dataset,
  load_dataset,
  create_large_dataset,
  create_small_dataset

using Gadfly, JLD

const srcdir = dirname(@__FILE__)
const default_datasetdir = realpath(srcdir * "/../dataset")

function export_dataset(name, dataset; datasetdir=default_datasetdir)
    path = datasetdir * "/" * name
    isdir(path) && rm(path, recursive=true)
    mkpath(path)
    open(path * "/summary.txt", "w") do f
        summary(f, dataset)
    end
    open(path * "/baseline.txt", "w") do f
        prediction = random_clustering(dataset)
        evaluation_summary(f, dataset, prediction)
    end
    save(path * "/dataset.jld", "dataset", dataset)
    draw(PNG(path * "/plothalf.png", 24cm, 16cm), plothalf(dataset))
    draw(PNG(path * "/plothalf_multi.png", 24cm, 16cm), plothalf_multi(dataset))
    draw(PNG(path * "/plotslot.png", 24cm, 16cm), plotslot(dataset))
    draw(PNG(path * "/plotslot_multi.png", 24cm, 16cm), plotslot_multi(dataset))
    draw(PNG(path * "/plotpca.png", 24cm, 16cm), plotpca(dataset))
end

function load_dataset(name; datasetdir=default_datasetdir)
    path = datasetdir * "/" * name
    load(path * "/dataset.jld", "dataset")
end
