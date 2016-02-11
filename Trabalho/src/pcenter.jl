include("dataset.jl")

export pcenter, pcenter_approx

function pcenter(dataset, k)
    data = map(first, dataset.data)

    centers = Array(Array{Int64,1}, 0)
    i = rand(1:length(data))
    push!(centers, data[i])

    min_dist(v) = minimum(map(c -> norm(c - v), centers))
    max_index() = indmax(map(min_dist, data))

    while length(centers) < k
        i = max_index()
        push!(centers, data[i])
    end

    cluster(v) = indmin(map(c -> norm(c - v), centers))

    assignments = zeros(Int, length(data))
    for (i, v) in enumerate(data)
        assignments[i] = cluster(v)
    end

    assignments
end

function pcenter_approx(dataset, k)
    assignments = pcenter(dataset, k)
    centermap = mapping(dataset, assignments, k)
    map(c -> centermap[c], assignments)
end
