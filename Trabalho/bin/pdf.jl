file = @__FILE__
output = realpath(dirname(file) * "/../output")
source = realpath(dirname(file) * "/../notebook")

cd(output)

notebooks = [
  "Dataset em Julia.ipynb",
  "Clustering em Julia.ipynb",
  "K-Means em Julia.ipynb",
  "P-Center em Julia.ipynb",
  "P-Median em Julia.ipynb",
  "Análise.ipynb"
]

result = zeros(Int, length(notebooks))

for (i, n) in enumerate(notebooks)
  println("Exporting PDF: $n")
  for t=1:5
    try
      run(`jupyter nbconvert --ExecutePreprocessor.timeout=600 "$source/$n" --to pdf --execute`)
      result[i] = t
      break
    catch e
      println("Error running notebook ", n, ":\n", e.msg)
    end
  end
end

println("\n")

for (i, n) in enumerate(notebooks)
  print(n, ": ")
  if result[i] == 0
    println("Fail")
  else
    println("Ok (tries ", result[i], ")")
  end
end
