include("dataset.jl")

export
  plothalf,
  plothalf_multi,
  plotslot,
  plotslot_multi,
  plotpca

using Gadfly, MultivariateStats

function halfmask(n)
    mask = zeros(n)
    middle = round(Int, n / 2)
    mask[1:middle] = 1
    mask
end

reversemask(mask) = ones(mask) - mask

function halfmasks(n)
    x = halfmask(n)
    y = reversemask(x)
    (x, y)
end

function reduce2d(data, masks)
    x = map(v -> norm(masks[1] .* v), data)
    y = map(v -> norm(masks[2] .* v), data)
    x, y
end

function plothalf(dataset)
    masks = halfmasks(dataset.dimension)

    g = Array(Layer, 0)

    for k=1:dataset.clusters
        kdata = data(dataset, k)
        x, y = reduce2d(kdata, masks)
        color = fill(string(k), length(kdata))
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
end

function plothalf_multi(dataset)
    masks = halfmasks(dataset.dimension)

    g = Array(Plot, 0)

    for k=1:dataset.clusters
        kdata = data(dataset, k)
        x, y = reduce2d(kdata, masks)
        p = plot(x=x, y=y, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
        push!(g, p)

    end

    hstack(g...)
end

function featuremask(features, slot, k)
    first = (k - 1) * slot + 1
    last = k * slot
    mask = zeros(features)
    mask[first:last] = 1
    mask
end

function featuremasks(features, slot, k)
    kmask = featuremask(features, slot, k)
    rmask = reversemask(kmask)
    (kmask, rmask)
end

function plotslot(dataset)
    g = Array(Layer, 0)

    for k=1:dataset.clusters
        masks = featuremasks(dataset.dimension, dataset.slot, k)
        kdata = data(dataset, k)
        x, y = reduce2d(kdata, masks)
        color = fill(string(k), length(kdata))
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
end

function plotslot_multi(dataset)
    g = Array(Plot, 0)

    for k=1:dataset.clusters
        masks = featuremasks(dataset.dimension, dataset.slot, k)
        kdata = data(dataset, k)
        x, y = reduce2d(kdata, masks)
        p = plot(x=x, y=y, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
        push!(g, p)
    end

    hstack(g...)
end

function plotpca(dataset)
    train = vector_matrix(dataset.input.data)
    model = fit(PCA, train; maxoutdim=2)

    g = Array(Layer, 0)

    for k=1:dataset.clusters
        kdata = data(dataset, k)
        kpoints = transform(model, vector_matrix(kdata))
        x = vec(kpoints[1,:])
        y = vec(kpoints[2,:])
        color = fill(string(k), size(kpoints, 2))
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g)
end
