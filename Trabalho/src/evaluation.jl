include("dataset.jl")

export SampleEvaluation,
  ClusterEvaluation,
  Evaluation,
  mapping,
  confusion_matrix,
  evaluation_summary

function mapping(dataset::Dataset, assignments::Vector{Int}, k::Int)
    centermap = zeros(Int, k)
    for i=1:dataset.clusters
        k_index = findin(dataset.target, i)
        centers = map(i -> assignments[i], k_index)
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
    matrix = zeros(Int, dataset.clusters, dataset.clusters)
    for p=1:length(prediction)
        i = dataset.target[p]
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
    c = map(k -> ClusterEvaluation(matrix, s, k), 1:dataset.clusters)
    Evaluation(matrix, s, c)
end

function Base.show(io::IO, s::SampleEvaluation)
    println(io, "Size: ", s.size)
    println(io, "Correct: ", s.correct)
    println(io, "Mistakes: ", s.mistakes)
    println(io, "Accuracy: ", round(100 * s.accuracy, 2), "%")
end

function Base.show(io::IO, c::ClusterEvaluation)
    println(io, "Cluster ", c.cluster)
    println(io)
    println(io, "Size: ", c.size)
    println(io, "Accuracy: ", round(100 * c.accuracy, 2), "%")
    println(io, "Precision: ", round(100 * c.precision, 2), "%")
    println(io, "Recall: ", round(100 * c.recall, 2), "%")
    println(io, "F-score: ", round(c.fscore , 2))
    println(io)
    println(io, "True Positive: ", c.truePositive, " (", round(100 * c.truePositiveShare, 2), "%)")
    println(io, "True Negative: ", c.trueNegative, " (", round(100 * c.trueNegativeShare, 2), "%)")
    println(io, "False Negative: ", c.falseNegative, " (", round(100 * c.falseNegativeShare, 2), "%)")
    println(io, "False Positive: ", c.falsePositive, " (", round(100 * c.falsePositiveShare, 2), "%)")
end

function Base.show(io::IO, r::Evaluation)
    println(io, r.sample)
    for k in r.clusters
        println(io, k)
    end
end

function evaluation_summary(io::IO, dataset, prediction; verbose=false)
    r = Evaluation(dataset, prediction)
    verbose && println(io, "Confusion Matrix:\n\n", r.matrix, "\n")
    print(io, r)
end

evaluation_summary(dataset, prediction; verbose=false) = evaluation_summary(STDOUT, dataset, prediction; verbose=verbose)

function test_dataset(dataset_name, predictor; output=STDOUT)
    dataset = load_dataset(dataset_name)
    k = dataset.clusters
    @time prediction = predictor(dataset, k)
    evaluation_summary(dataset, prediction; verbose=true)
end
