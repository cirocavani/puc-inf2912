include("dataset.jl")

export random_clustering

function distribution(dataset)
    clusters = Array(Float64, dataset.clusters)
    size = 0
    for k=1:dataset.clusters
        size += count(dataset, k)
        clusters[k] = size
    end
    clusters /= size
    clusters
end

function choosek(distribution)
    r = rand()
    for k=1:length(distribution)
        if r <= distribution[k]
            return k
        end
    end
    return 0
end

function random_clustering(dataset)
    cdf = distribution(dataset)
    clusters = Array(Int, dataset.size)
    for i=1:length(clusters)
        clusters[i] = choosek(cdf)
    end
    clusters
end
