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
    x = map(t -> norm(masks[1] .* t[1]), data)
    y = map(t -> norm(masks[2] .* t[1]), data)
    k = map(t -> string(t[2]), data)
    x, y, k
end

function plothalf(dataset)
    masks = halfmasks(dataset.features)

    g = Array(Layer, 0)

    for k=1:dataset.groups
        kdata = data(dataset, k)
        x, y, color = reduce2d(kdata, masks)
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
end

function plothalf_multi(dataset)
    masks = halfmasks(dataset.features)

    g = Array(Plot, 0)

    for k=1:dataset.groups
        kdata = data(dataset, k)
        x, y, _ = reduce2d(kdata, masks)
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

    for k=1:dataset.groups
        masks = featuremasks(dataset.features, dataset.slot, k)
        kdata = data(dataset, k)
        x, y, color = reduce2d(kdata, masks)
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
end

function plotslot_multi(dataset)
    g = Array(Plot, 0)

    for k=1:dataset.groups
        masks = featuremasks(dataset.features, dataset.slot, k)
        kdata = data(dataset, k)
        x, y, _ = reduce2d(kdata, masks)
        p = plot(x=x, y=y, Scale.x_continuous(minvalue=0, maxvalue=10), Scale.y_continuous(minvalue=0, maxvalue=10))
        push!(g, p)
    end

    hstack(g...)
end

matrix(data) = float(hcat(map(first, data)...))

function plotpca(dataset)
    train = matrix(dataset.data)
    model = fit(PCA, train; maxoutdim=2)

    g = Array(Layer, 0)

    for k=1:dataset.groups
        kdata = data(dataset, k)
        kpoints = transform(model, matrix(kdata))
        x = vec(kpoints[1,:])
        y = vec(kpoints[2,:])
        color = fill(string(k), size(kpoints, 2))
        push!(g, layer(x=x, y=y, color=color, Geom.point)...)
    end

    plot(g)
end
