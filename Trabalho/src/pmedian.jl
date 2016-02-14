include("dataset.jl")

export pmedian, pmedian_approx

using JuMP

"Algoritmo de clusterização P-Median (Programan Inteiro, Facility Location Problem)."
function pmedian(input::Input, k::Int)
    n = input.size
    d = dist(input.data)

    m = Model()

    @defVar(m, 0 <= x[1:n,1:n] <= 1)
    @defVar(m, y[1:n], Bin)

    # add the constraint that the amount that facility j can serve
    # customer x is at most 1 if facility j is opened, and 0 otherwise.
    for i=1:n, j=1:n
        @addConstraint(m, x[i,j] <= y[j])
    end

    # add the constraint that the amount that each customer must
    # be served
    for i=1:n
        @addConstraint(m, sum{x[i,j], j=1:n} == 1)
    end

    # add the constraint that at most 3 facilities can be opened.
    @addConstraint(m, sum{y[j], j=1:n} <= k)

    # add the objective.
    @setObjective(m, Min, sum{d[i,j] * x[i,j], i=1:n, j=1:n})

    status = solve(m)
    if status != :Optimal
        error("Wrong status (not optimal): $status")
    end

    centers = getValue(y)[:]
    clusters = getValue(x)[:,:]

    assignments = zeros(Int, n)
    _k = 0
    for j=1:n
        centers[j] == 0.0 && continue
        _k += 1
        for i=1:n
            clusters[i,j] == 0.0 && continue
            assignments[i] = _k
        end
    end
    assignments
end

pmedian(dataset::Dataset, k::Int) = pmedian(dataset.input, k)

"Algoritmo de clusterização P-Median (Programan Inteiro, Facility Location Problem) \
aproximado para os grupos pré-definidos do dataset."
function pmedian_approx(dataset::Dataset, k::Int)
    assignments = pmedian(dataset, k)
    centermap = mapping(dataset, assignments, k)
    map(c -> centermap[c], assignments)
end
