# Trabalho de Implementação

## INF2912 - Otimização Combinatória

Algoritmos de clusterização.

### Setup do Gurobi no Jupyter

Esse procedimento descreve como criar um ambiente isolado do Python para instalação do Gurobi como kernel do Jupyter.

Pré-requisito:

* Gurobi instalado e funcionando
* Jupyter instalado e funcionando

Procedimento:

Passos a serem executados em um terminal.

(esse procedimento assume que a pasta atual é `/home/cavani/puc/inf2912/Trabalho`)

1. Ajuste da Configuração

    Altere o arquivo `gurobi_python2/kernel.json` com os parâmetros adequados.

        /home/cavani/puc/gurobikey-puc2015/gurobi.lic -> caminho da chave do Gurobi
        /home/cavani/puc/gurobi563/linux64/lib -> caminho da biblioteca do Gurobi
        /home/cavani/puc/inf2912/Trabalho/gurobi/bin/python -> caminho do ambiente local Python2

2. Ambiente local do Python2

        virtualenv -p python2.7 gurobi
        source gurobi/bin/activate

3. Kernel do Jupyter

        pip install ipython[kernel]
        jupyter kernelspec install --user --replace gurobi_python2

4. Instalação do binding Python do Gurobi

        cd /home/cavani/puc/gurobi563/linux64
        python setup.py install

5. Pacotes usados nos Notebooks

        pip install -r requirements.txt


A sessão do terminal pode ser encerrada.

O novo kernel `Gurobi (Python 2)` fica disponível no Jupyter.

