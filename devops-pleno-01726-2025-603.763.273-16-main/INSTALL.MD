
# Instalações

Siga as etapas abaixo para instalar as ferramentas necessárias.

As instalações são baseadas no Sistema Operacional Linux.

## NPM

Para instalar o frontend do projeto, você precisará do NPM para instalar as dependências do Javascript.

Instruções para instalação: <https://docs.npmjs.com/downloading-and-installing-node-js-and-npm>

## Python

Para instalar o backend do projeto, você precisará ter o Python instalado. A versão precisará ser superior a 3.x.

Instruções para a instalação: <https://python.org.br/instalacao-linux>

### Virtual Env

Para criação de um novo virtual env, digite o comando: `python3 -m venv nome_virtual_env`.

Mais instruções do virtual env necessário estarão no arquivo START.MD, na seção Backend.

Link da documentação do venv: <https://docs.python.org/3/library/venv.html>

## Docker

Para poder trabalhar com containers você precisará instalar o Docker.

Instruções para a instalação: <https://docs.docker.com/engine/install>

### Docker Hub

Para poder enviar a imagem para o Docker Hub (registro de containers público), você precisará criar uma conta no Docker Hub.

Link: <https://hub.docker.com>

Após criar a conta, você poderá executar o comando: `docker login` e informar o usuário e senha criados na plataforma para autenticar e poder fazer o push das imagens.

## Docker Compose

Para poder trabalhar com a orquestração dos containers no ambiente de desenvolvimento, você precisará instalar o Docker Compose.

Instruções para a instalação: <https://docs.docker.com/compose/install>

## Kubernetes

Para poder trabalhar com o Kubernetes, uma forma simples de fazê-lo é utilizando a ferramenta Kind.

Instruções para a instalação: <https://kind.sigs.k8s.io/docs/user/quick-start/#installation>

### Criando um novo cluster

Para criar um cluster Kubernetes: `kind create cluster --name k8s-prova`

### Kubectl

Para ter acessso aos comandos que manipulam objetos do Kubernetes, instale o Kubectl.

Instruções para a instalação: <https://kubernetes.io/docs/tasks/tools/install-kubectl-linux>

Exemplo de comando: `kubectl get nodes`
