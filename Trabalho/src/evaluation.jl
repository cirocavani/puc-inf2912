include("dataset.jl")

export SampleEvaluation,
  ClusterEvaluation,
  Evaluation,
  mapping,
  confusion_matrix,
  evaluation_summary

function mapping(dataset, assignments, k)
    centermap = zeros(Int, k)
    groups = map(v -> v[2], dataset.data)
    for i=1:dataset.groups
        g_index = findin(groups, i)
        centers = map(i -> assignments[i], g_index)
        counts = hist(centers, 0:k)[2]
        center_key = indmax(counts)
        if centermap[center_key] != 0
            error("Center already mapped: $(center_key) -> $(centermap[center_key]), now $i?")
        end
        centermap[center_key] = i
    end
    centermap
end

function confusion_matrix(dataset, prediction)
    matrix = zeros(Int, dataset.groups, dataset.groups)
    for p=1:length(prediction)
        i = dataset.data[p][2]
        j = prediction[p]
        matrix[i,j] += 1
    end
    matrix
end

immutable SampleEvaluation
    size::Int
    correct::Int
    mistakes::Int
    accuracy::Float64
end

immutable ClusterEvaluation
    cluster::Int
    size::Int

    truePositive::Int
    truePositiveShare::Float64
    trueNegative::Int
    trueNegativeShare::Float64

    falseNegative::Int
    falseNegativeShare::Float64
    falsePositive::Int
    falsePositiveShare::Float64

    precision::Float64
    recall::Float64
    fscore::Float64
    accuracy::Float64
end

immutable Evaluation
    matrix::Array{Int, 2}
    sample::SampleEvaluation
    clusters::Array{ClusterEvaluation, 1}
end

function SampleEvaluation(matrix)
    size = sum(matrix)
    correct = sum(diag(matrix))
    mistakes = size - correct
    accuracy = correct / size

    SampleEvaluation(size, correct, mistakes, accuracy)
end

function ClusterEvaluation(matrix, s, k)
    kn = sum(matrix[k,:])

    ktp = matrix[k,k]
    ktpp = ktp / kn

    kfn = kn - ktp
    kfnp = kfn / s.mistakes

    kfp = sum(matrix[:,k]) - ktp
    kfpp = kfp / s.mistakes

    ktn = s.size - kfn - kfp - ktp
    ktnp = ktn / (s.size - kn)

    kacc = (ktp + ktn) / s.size
    kprecision = ktp / (ktp + kfp)
    krecall = ktp / (ktp + kfn)
    kfscore = 2 * kprecision * krecall / (kprecision + krecall)

    ClusterEvaluation(k, kn, ktp, ktpp, ktn, ktnp, kfn, kfnp, kfp, kfpp, kprecision, krecall, kfscore, kacc)
end

function Evaluation(dataset, prediction)
    matrix = confusion_matrix(dataset, prediction)
    s = SampleEvaluation(matrix)
    c = map(k -> ClusterEvaluation(matrix, s, k), 1:dataset.groups)
    Evaluation(matrix, s, c)
end

function Base.show(io::IO, s::SampleEvaluation)
    println(io, "Tamanho: ", s.size)
    println(io, "Acertos: ", s.correct)
    println(io, "Erros: ", s.mistakes)
    println(io, "Accuracy: ", round(100 * s.accuracy, 2), "%")
end

function Base.show(io::IO, c::ClusterEvaluation)
    println(io, "Cluster ", c.cluster)
    println(io)
    println(io, "Tamanho: ", c.size)
    println(io, "Accuracy: ", round(100 * c.accuracy, 2), "%")
    println(io, "Precision: ", round(100 * c.precision, 2), "%")
    println(io, "Recall: ", round(100 * c.recall, 2), "%")
    println(io, "F-score: ", round(c.fscore , 2))
    println(io)
    println(io, "Acerto positivo: ", c.truePositive, " (", round(100 * c.truePositiveShare, 2), "%)")
    println(io, "Acerto negativo: ", c.trueNegative, " (", round(100 * c.trueNegativeShare, 2), "%)")
    println(io, "Falso negativo: ", c.falseNegative, " (", round(100 * c.falseNegativeShare, 2), "%)")
    println(io, "Falso positivo: ", c.falsePositive, " (", round(100 * c.falsePositiveShare, 2), "%)")
end

function Base.show(io::IO, r::Evaluation)
    println(io, r.sample)
    for k in r.clusters
        println(io, k)
    end
end

function evaluation_summary(io::IO, dataset, prediction; verbose=false)
    r = Evaluation(dataset, prediction)
    verbose && println(io, "Matriz de Confusão:\n\n", r.matrix, "\n")
    print(io, r)
end

evaluation_summary(dataset, prediction; verbose=false) = evaluation_summary(STDOUT, dataset, prediction; verbose=verbose)
