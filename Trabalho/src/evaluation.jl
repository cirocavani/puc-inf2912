include("dataset.jl")

export confusion_matrix, evaluation_summary, mapping

function confusion_matrix(dataset, prediction)
    matrix = zeros(Int, dataset.groups, dataset.groups)
    for p=1:length(prediction)
        i = dataset.data[p][2]
        j = prediction[p]
        matrix[i,j] += 1
    end
    matrix
end

function evaluation_summary(io::IO, dataset, prediction)
    matrix = confusion_matrix(dataset, prediction)

    n = sum(matrix)
    tp = sum(diag(matrix))
    fn = sum(triu(matrix)) - tp
    fp = sum(tril(matrix)) - tp

    precision = tp / (tp + fp)
    recall = tp / (tp + fn)
    fscore = 2 * precision * recall / (precision + recall)

    println(io, "Precision: ", round(100 * precision, 2), "%")
    println(io, "Recall: ", round(100 * recall, 2), "%")
    println(io, "F-score: ", round(fscore , 2))
    println(io)
    println(io, "Número de predições: ", n)
    println(io, "Acertos: ", tp, " (", round(100 * tp / n, 2), "%)")
    println(io, "Falso negativo: ", fn, " (", round(100 * fn / n, 2), "%)")
    println(io, "Falso positivo: ", fp, " (", round(100 * fp / n, 2), "%)")

    for k=1:dataset.groups
        kn = sum(matrix[k,:])
        ktp = matrix[k,k]
        kfn = kn - ktp
        kfp = sum(matrix[:,k]) - ktp
        ktn = n - kfn - kfp - ktp
        kacc = (ktp + ktn) / n
        kprecision = ktp / (ktp + kfp)
        krecall = ktp / (ktp + kfn)
        kfscore = 2 * kprecision * krecall / (kprecision + krecall)
        println(io)
        println(io, "Cluster ", k)
        println(io)
        println(io, "Objetos: ", kn)
        println(io, "Accuracy: ", round(100 * kacc, 2), "%")
        println(io, "Precision: ", round(100 * kprecision, 2), "%")
        println(io, "Recall: ", round(100 * krecall, 2), "%")
        println(io, "F-score: ", round(kfscore , 2))
        println(io)
        println(io, "Acerto positivo: ", ktp, " (", round(100 * ktp / kn, 2), "%)")
        println(io, "Acerto negativo: ", ktn, " (", round(100 * ktn / (n - kn), 2), "%)")
        println(io, "Falso negativo: ", kfn, " (", round(100 * kfn / fn, 2), "%)")
        println(io, "Falso positivo: ", kfp, " (", round(100 * kfp / fp, 2), "%)")
    end
end

evaluation_summary(dataset, prediction) = evaluation_summary(STDOUT, dataset, prediction)

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
