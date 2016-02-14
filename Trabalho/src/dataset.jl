export Input,
  Dataset,
  data,
  count,
  summary,
  dist,
  vector_matrix

"gera a distribuição de objetos para os grupos"
function group_size(g, n, n_min, n_max)
    num_g = Array(Int, g)
    sum = 0
    for i=1:g
        num_g[i] = rand(n_min:n_max)
        sum += num_g[i]
    end
    correct = n / sum
    sum = 0
    for i=1:g
        num_g[i] = round(Int, num_g[i] * correct)
        sum += num_g[i]
    end
    if sum != n
        num_g[g] += n - sum
    end
    num_g
end

"máscara de características para cada grupo sem interseção"
function group_mask(g, c, c_y)
    char_g = fill(-1, c)
    index = 1
    for i=1:g, j=1:c_y
        char_g[index] = i
        index += 1
    end
    char_g
end

"""gera objetos para grupos seguindo a distribuição num_g,
a máscara char_g e a probabilidade p de ativação"""
function generate_data(num_g, char_g, p)
    data = Array(Tuple{Array{Int,1},Int}, 0)
    for i=1:length(num_g),j=1:num_g[i]
        vect = zeros(Int, length(char_g))
        for k=1:length(vect)
            if char_g[k] == i
                vect[k] = rand() < p ? 1 : 0
            elseif char_g[k] != -1
                vect[k] = rand() < 1 - p ? 1 : 0
            else
                vect[k] = rand() < 0.5 ? 1 : 0
            end
        end
        push!(data, (vect, i))
    end
    data
end

"gerador de instâncias para o problema de clusterização"
function instance_generator(n, c, c_y, p, g, n_min, n_max)
    if c < g * c_y
        error("c_y too big")
    end

    num_g = group_size(g, n, n_min, n_max)
    char_g = group_mask(g, c, c_y)
    data = generate_data(num_g, char_g, p)
    data
end

immutable Input
    data::Array{Vector{Int}, 1}
    size::Int
    dimension::Int

    Input(data::Array{Vector{Int}, 1}) = begin
        size = length(data)
        if size == 0
            error("empty data")
        end
        dimension = length(data[1])
        if dimension == 0
            error("empty dimension")
        end
        for i in data
            if length(i) != dimension
                error("wrong dimension: expected $dimension, actual $(length(i))")
            end
        end

        new(data, size, dimension)
    end
end

immutable Dataset
    clusters::Int
    dimension::Int
    slot::Int
    activation_p::Float64
    size::Int
    size_min::Int
    size_max::Int
    input::Input
    target::Vector{Int}

    Dataset(; clusters=3, size=1000, size_min=0, size_max=0, dimension=200, slot=40, activation_p=0.8) = begin
        if size < 10
            error("minimum 10")
        end
        if clusters > size
            error("too many clusters")
        end
        if dimension < clusters * slot
            error("slot too big")
        end

        if size_max == 0
            size_max = round(Int, 1.2 * size / clusters)
        end
        if size_min == 0
            size_min = round(Int, size_max / 2)
        end
        if size_max * clusters < size
            error("size_max too tight")
        end

        data = instance_generator(size, dimension, slot, activation_p, clusters, size_min, size_max)
        shuffle!(data)

        input = Input(map(t -> t[1], data))
        target = map(t -> t[2], data)

        new(clusters, dimension, slot, activation_p, size, size_min, size_max, input, target)
    end
end

data(ds, k) = map(i -> ds.input.data[i], findin(ds.target, k))
count(ds, k) = length(data(ds, k))

"Sumário do Dataset"
function summary(io::IO, ds::Dataset)
    println(io, "Clusters: ", ds.clusters)
    println(io, "Dimension (features): ", ds.dimension)
    println(io, "Features per Cluster: ", ds.slot)
    println(io, "Probability of Activation: ", ds.activation_p)
    println(io)
    println(io, "Size: ", ds.size)
    println(io, "Min Cluster size: ", ds.size_min)
    println(io, "Max Cluster size: ", ds.size_max)
    for k=1:ds.clusters
        println(io, "Cluster ", k, " size: ", count(ds, k))
    end
end

"Sumário do Dataset"
summary(ds::Dataset) = summary(STDOUT, ds)

vector_matrix(data::Array{Vector{Int}, 1}) = float(hcat(data...))

function dist(data::Array{Vector{Int}, 1})
    n = length(data)
    d = zeros(n, n)
    for i=1:n, j=i+1:n
        dist = norm(data[i] - data[j])
        d[i,j] = dist
        d[j,i] = dist
    end
    Symmetric(d)
end
