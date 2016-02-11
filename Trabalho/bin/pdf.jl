cd("output")

notebooks = [
  "Dataset em Julia.ipynb",
  "Clustering em Julia.ipynb",
  "K-Means em Julia.ipynb",
  "P-Center em Julia.ipynb",
  "P-Median em Julia.ipynb",
  "Análise.ipynb"
]

for n in notebooks
  println("Exporting PDF: $n")
  run(`jupyter nbconvert "../notebook/$n" --to pdf`)
end
