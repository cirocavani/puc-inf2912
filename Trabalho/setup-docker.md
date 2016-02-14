# Trabalho de Implementação

## INF2912 - Otimização Combinatória

Algoritmos de clusterização.

### Setup no Docker

Esse é o procedimento para criação de um container Docker para execução desse projeto.

A pasta atual (`pwd`) deve ser a `Tabalho` do repositório git.

Esse diretório é compartilhado com o container e só funciona no Linux.

Para outros sistemas, a solução é clonar o repositóro dentro do container e fazer os devidos ajustes no procedimento.

TODO: criar um Docerfile para o procedimento (com e sem compartilhamento)

...

Criação do container Docker com Ubuntu (o diretório local será montado na pasta `/opt/clustering`).

    docker run -i -t --name=inf2912 --hostname=inf2912 -v `pwd`:/opt/clustering ubuntu:14.04 /bin/bash

> (Sem o compartilhamento do diretório)
>
>   docker run -i -t --name=inf2912 --hostname=inf2912 ubuntu:14.04 /bin/bash

Configuração do Usuário da Aplicação (sem senha).

    useradd -m -d /clustering -G sudo clustering
    passwd -d clustering
    su - clustering

Atualização do Ubuntu.

    sudo apt-get update
    sudo apt-get upgrade -y

Evita a instalação de pacotes desnecessários.

    echo 'APT::Install-Recommends "0";' > 01norecommend
    sudo mv 01norecommend /etc/apt/apt.conf.d

Compilação de dependências do Python e de Julia.

    sudo apt-get install -y build-essential

Instalação do Python (Jupyter).

    sudo apt-get install -y build-essential python python-dev python-pip

Geração de PDF de um Notebook.

    sudo apt-get install -y texlive texlive-generic-recommended texlive-latex-extra inkscape pandoc

Instalação do Jupyter.

    sudo pip install --upgrade jupyter

Instalação de Julia.

    sudo apt-get install -y wget
    wget https://julialang.s3.amazonaws.com/bin/linux/x64/0.4/julia-0.4.3-linux-x86_64.tar.gz

    sudo mkdir /opt/julia-0.4
    sudo tar zxf julia-0.4.3-linux-x86_64.tar.gz -C /opt/julia-0.4 --strip-components=1
    rm julia-0.4.3-linux-x86_64.tar.gz

Dependência dos pacotes de Julia.

    sudo apt-get install -y git libnettle4 gettext libcairo2 libpango1.0 hdf5-tools

> (Sem o compartilhamento do diretório)
>
>   git clone https://github.com/cirocavani/puc-inf2912.git inf2912
>   sudo ln -s `pwd`/inf2912/Trabalho /opt/clustering

Instalação da Aplicação.

    /opt/julia-0.4/bin/julia /opt/clustering/bin/setup.jl

Execução do Jupyter.

    echo "jupyter notebook --ip='0.0.0.0' --no-browser --notebook-dir=/opt/clustering" > jupyter-start.sh
    chmod +x jupyter-start.sh

Saindo do container.

    exit
    exit

O Container está pronto.

(Opicional) Salvando a Imagem da Aplicação.

    docker export -o docker-image.tar inf2912

O arquivo tem ~1.4G.

### Executando o Jupyter

Iniciando o container.

    docker start inf2912

IP do Container no Host.

    docker exec inf2912 cat /etc/hosts
    > (...)
    > 172.17.0.2	inf2912

Executando o Jupyter.

    docker exec inf2912 su -c "/clustering/jupyter-start.sh" - clustering
    > (...)

Abra o Navegador local no endereço `<IP_DO_CONTAINER>:8888` para acessar o Jupyter.
