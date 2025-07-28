## 1\. Visão Geral do Projeto

Este projeto tem como objetivo principal demonstrar a construção e implantação de uma aplicação web Fullstack modularizada em um ambiente conteinerizado e orquestrado por Kubernetes. O trabalho simula um ciclo completo de desenvolvimento e deploy em um cenário DevOps, incluindo a automação do build e push de imagens Docker para um registro e a orquestração de recursos no cluster.

### Componentes da Aplicação:

  * **Backend:** Desenvolvido em Python com o framework FastAPI, este componente é responsável pela lógica de negócios da aplicação, processamento de dados e interação com o banco de dados. Ele expõe uma API RESTful para comunicação com o Frontend.
  * **Frontend:** Uma aplicação web construída com Vue.js, que fornece a interface de usuário interativa. Ela consome os serviços da API do Backend para exibir e manipular dados.
  * **Banco de Dados:** PostgreSQL, um sistema de gerenciamento de banco de dados relacional robusto, utilizado para a persistência dos dados da aplicação.
  * **CronJob:** Uma rotina agendada, implementada em Python, responsável por tarefas de manutenção como a exclusão periódica de arquivos CSV antigos. Isso ilustra a capacidade de agendar e executar tarefas em segundo plano no Kubernetes.

### Tecnologias e Ferramentas Utilizadas:

  * **Contêineres:** Docker (para empacotar os serviços em unidades isoladas e portáveis).
  * **Orquestração de Contêineres:**
      * **Docker Compose:** Utilizado para o ambiente de desenvolvimento local, facilitando a orquestração de múltiplos contêineres e suas dependências.
      * **Kubernetes:** A plataforma principal para o ambiente de produção, fornecendo recursos de escalabilidade, alta disponibilidade e gerenciamento avançado de contêineres.
  * **Linguagens/Frameworks:** Python (FastAPI, Uvicorn), JavaScript (Vue.js), SQL (PostgreSQL), Shell Scripting (para automação de CI/CD).
  * **Servidor Web (Frontend):** Nginx (utilizado na imagem Docker do Frontend em produção para servir os arquivos estáticos da aplicação Vue.js).
  * **Versionamento:** Git (para controle de versão do código fonte).
  * **Ferramentas Kubernetes:** `kubectl` (ferramenta de linha de comando para interagir com o cluster) e **Minikube** (para criar um cluster Kubernetes local de desenvolvimento/teste).

## 2\. Pré-requisitos

Para replicar e executar este ambiente com sucesso, as seguintes ferramentas devem estar instaladas e configuradas no sistema operacional:

  * **Git:** Para clonar o repositório do projeto.
      * [Guia de Instalação do Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  * **Docker Desktop (ou Docker Engine + Docker Compose v2):** Essencial para construir as imagens Docker e, no caso do Docker Desktop, já inclui o Docker Compose e pode ser usado como driver para o Minikube.
      * [Instalar Docker Desktop](https://www.docker.com/products/docker-desktop/)
      * [Instalar Docker Engine e Compose v2 (Linux)](https://docs.docker.com/engine/install/)
  * **kubectl:** A ferramenta de linha de comando oficial para interagir com clusters Kubernetes.
      * [Instalar kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  * **Minikube (ou Kind, ou acesso a um cluster Kubernetes):** Para criar e gerenciar um cluster Kubernetes local. Minikube é altamente recomendado para este projeto.
      * [Instalar Minikube](https://minikube.sigs.k8s.io/docs/start/)
      * [Instalar Kind](https://www.google.com/search?q=https://kind.sigs.k8s.io/docs/user/quick-start/%23installation)
  * **Conta no Docker Hub:** Necessária para publicar as imagens Docker que serão utilizadas pelo Kubernetes.
      * [Criar uma conta no Docker Hub](https://hub.docker.com/signup)
  * **Git Bash / WSL (Windows Subsystem for Linux):** Recomendado para usuários Windows para uma melhor experiência de linha de comando compatível com scripts Linux.

## 3\. Ambiente de Desenvolvimento (Docker Compose)

Para um ciclo de desenvolvimento e testes eficiente e rápido, o Docker Compose é a ferramenta ideal para orquestrar os múltiplos serviços da aplicação localmente.

### Variáveis de Ambiente (.env)

O arquivo `.env` deve ser criado na **raiz do projeto** (`./.env`) e conter as variáveis de ambiente necessárias para a comunicação entre os serviços. **Este arquivo não deve ser versionado no Git** para evitar a exposição de informações sensíveis. Utilize o `.env.dist` como modelo para criar sua versão `.env`.

1.  **Criação do arquivo `.env`**:

    ```bash
    cp .env.dist .env
    ```

2.  **Edição do `.env`**: Preenchimento com os valores apropriados para o ambiente local. O `DATABASE_HOST` deve ser `db`, que é o nome do serviço do banco de dados conforme definido no `docker-compose.yml`.

    ```env
    # Conteúdo esperado em .env na raiz do projeto
    DATABASE_HOST=db
    DATABASE_PORT=5432
    DATABASE_USER=postgres
    DATABASE_PASS=postgres
    DATABASE_DBNAME=produtos_db
    UPLOAD_DIR=/app/uploads

    # Variáveis adicionais para o driver Psycopg2 (opcionais, mas boas para consistência)
    PGHOST=db
    PGPORT=5432
    PGUSER=postgres
    PGPASSWORD=postgres
    PGDATABASE=produtos_db
    ```

### Build e Execução

Para levantar todos os serviços em modo de desenvolvimento, a partir da raiz do projeto:

1.  **Navegação até o diretório raiz do projeto**:
    ```bash
    cd /caminho/do/seu/projeto/devops-pleno-01726-2025-603.763.273-16-main/
    ```
    *Certifique-se de substituir `/caminho/do/seu/projeto/...` pelo caminho real para o seu repositório.*
2.  **Construção das imagens e inicialização dos contêineres**: O `--build` garante que as imagens mais recentes sejam construídas a partir dos `Dockerfiles` definidos no `docker-compose.yml`.
    ```bash
    docker compose up --build
    ```
    *Para rodar os serviços em segundo plano, adicione a flag `-d`: `docker compose up --build -d`.*

### Acessando os Serviços

Após a inicialização bem-sucedida dos contêineres:

  * **Frontend:** A aplicação pode ser acessada no navegador através de: `http://localhost:8080`
  * **Backend:** A documentação interativa da API (Swagger UI) está disponível em: `http://localhost:8081/docs`

### Comandos Úteis do Docker Compose

Estes comandos são executados a partir da raiz do projeto:

  * **Listar contêineres e seus status:**
    ```bash
    docker compose ps
    ```
  * **Ver logs de um serviço em tempo real (ex: backend):**
    ```bash
    docker compose logs -f backend
    ```
  * **Parar e remover todos os contêineres, redes e volumes (dados persistentes):**
    ```bash
    docker compose down -v
    ```
  * **Entrar no shell de um contêiner (ex: backend) para depuração:**
    ```bash
    docker compose exec backend bash
    ```

## 4\. Ambiente de Produção (Kubernetes)

O ambiente de produção é construído e gerenciado utilizando Kubernetes, proporcionando escalabilidade, resiliência e alta disponibilidade para a aplicação. A implantação envolve o build e publicação de imagens Docker e a aplicação de manifestos Kubernetes.

### Configuração do Minikube

Se o Minikube estiver sendo utilizado para o cluster local, os seguintes passos são necessários para configurá-lo:

1.  **Inicialização do Minikube:**
    ```bash
    minikube start --driver=docker # Inicia o Minikube usando o driver Docker (recomendado para integração com Docker Desktop)
    ```
    *A opção `--driver=docker` pode ser omitida se já houver um driver configurado ou outra preferência.*
2.  **Habilitar add-ons (opcional):**
    ```bash
    minikube addons enable ingress # Necessário se o Ingress for utilizado para acesso externo
    ```
3.  **Configuração do kubectl para usar o contexto do Minikube:**
    ```bash
    kubectl config use-context minikube # Garante que os comandos kubectl interajam com o cluster Minikube
    ```

### Configuração dos Dockerfiles

Os `Dockerfiles` (`backend/Dockerfile` e `frontend/Dockerfile`) são projetados com **Multi-stage Builds**. Esta técnica é crucial para otimizar o tamanho final das imagens Docker, resultando em contêineres mais leves e eficientes para o ambiente de produção. Além disso, as configurações são injetadas via **ConfigMaps e Secrets do Kubernetes** em tempo de execução, garantindo que os `Dockerfiles` sejam agnósticos a variáveis de ambiente hardcoded e não copiem arquivos `.env`.

**`backend/Dockerfile` (Exemplo com Multi-stage Build):**

```dockerfile
# --- Stage 1: Build Stage (Instala as dependências Python) ---
FROM python:3.10.12-slim-buster AS builder

WORKDIR /app

# Copia apenas o arquivo de dependências para aproveitar o cache do Docker
COPY requirements.txt .
# Instala as dependências
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# --- Stage 2: Final Stage (Ambiente de execução otimizado) ---
FROM python:3.10.12-slim-buster

WORKDIR /app

# Copia as dependências instaladas do stage 'builder'
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages

# Copia o código fonte da aplicação e scripts de inicialização
COPY ./src ./src
COPY cron.sh .
COPY start.sh .

# Cria o diretório de uploads
RUN mkdir -p ./uploads

# Garante que os scripts sejam executáveis
RUN chmod +x *.sh

# Define a variável de ambiente PYTHONPATH para o código fonte
ENV PYTHONPATH=/app/src

# Comando para iniciar a aplicação
CMD ["bash", "start.sh"]
```

**`frontend/Dockerfile` (Exemplo com Multi-stage Build para Vue.js/Nginx):**

```dockerfile
# --- Stage 1: Build Stage (Compila a aplicação Vue.js) ---
FROM node:18-alpine AS builder

WORKDIR /app

# Copia package.json e package-lock.json para instalar dependências e aproveitar o cache
COPY frontend/package*.json ./
RUN npm install

# Copia todo o código fonte do frontend
COPY frontend/ .

# Executa o build da aplicação Vue.js
RUN npm run build

# --- Stage 2: Final Stage (Servir a aplicação com Nginx) ---
FROM nginx:alpine

# Remove a configuração padrão do Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copia os arquivos estáticos compilados do stage 'builder' para o diretório de serviço do Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Copia a sua configuração Nginx customizada
COPY frontend/nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Expõe a porta 80 (padrão para HTTP)
EXPOSE 80

# Comando para iniciar o Nginx em foreground
CMD ["nginx", "-g", "daemon off;"]
```

*Certifique-se de que o arquivo `frontend/nginx/nginx.conf` existe com sua configuração Nginx. Um exemplo básico é:*

```nginx
# frontend/nginx/nginx.conf
server {
    listen 80;
    server_name localhost; # Pode ser ajustado para seu domínio real em produção

    location / {
        root /usr/share/nginx/html;
        index index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    # Configuração para páginas de erro
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
```

**`.dockerignore`:** É fundamental ter arquivos `.dockerignore` nas pastas `backend/` e `frontend/`. Eles instruem o Docker a ignorar arquivos e pastas desnecessárias (ex: `.git`, `node_modules`, `venv`, arquivos de cache) durante o processo de build da imagem, o que acelera o build e reduz significativamente o tamanho final da imagem.

### Pipelines de CI/CD (Simulação - Build e Publicação de Imagens Docker)

Um script shell (`scripts/deploy.sh`) é fornecido para simular as etapas cruciais de um pipeline de CI/CD. Este script automatiza o processo de build das imagens Docker, a geração de tags dinâmicas, o push dessas imagens para o Docker Hub e a atualização dos nomes das imagens nos manifestos Kubernetes.

#### Autenticação no Docker Hub

Antes de executar o script de deploy, é necessário estar autenticado na conta do Docker Hub para poder fazer o push das imagens.

```bash
docker login
# Será solicitado seu Docker ID e Password. Digite-os quando solicitado.
```

#### Script do Pipeline (`scripts/deploy.sh`)

Este script deve ser executado a partir da **raiz do projeto**.

```bash
#!/bin/bash

# --- Configurações Iniciais ---
# !!! IMPORTANTE: Substitua 'seu_dockerhub_username' pelo seu nome de usuário real do Docker Hub !!!
DOCKER_USERNAME="seu_dockerhub_username"
# !!! IMPORTANTE: Substitua 'seu_repo_backend' e 'seu_repo_frontend' pelos nomes dos seus repositórios no Docker Hub !!!
REPO_BACKEND="seu_repo_backend"           # Exemplo: meu-app-backend
REPO_FRONTEND="seu_repo_frontend"         # Exemplo: meu-app-frontend

# Gera uma tag única para cada build (timestamp para este exemplo)
# Isso garante que cada nova imagem tenha uma tag imutável, facilitando rollbacks.
TAG=$(date +%Y%m%d%H%M%S) # Formato: YYYYMMDDHHMMSS

# --- Funções Auxiliares do Pipeline ---

# Função para construir e fazer push de uma imagem Docker
build_and_push() {
    local service_dir=$1  # Diretório do serviço (ex: "backend", "frontend")
    local repo_name=$2    # Nome do repositório no Docker Hub (ex: "seu_repo_backend")
    local dockerfile_path="$service_dir/Dockerfile" # Caminho completo para o Dockerfile

    echo "--- Iniciando Build e Push da imagem para o serviço: ${service_dir} ---"
    echo "  Dockerfile de origem: ${dockerfile_path}"
    echo "  Tag da imagem a ser criada: ${DOCKER_USERNAME}/${repo_name}:${TAG}"

    # Executa o build da imagem Docker
    # A flag --platform linux/amd64 é crucial para garantir compatibilidade com a arquitetura padrão do Minikube.
    docker build --platform linux/amd64 -t ${DOCKER_USERNAME}/${repo_name}:${TAG} -f "${dockerfile_path}" "./${service_dir}"

    # Verifica se o comando docker build foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Erro: Falha no processo de build da imagem para o serviço ${service_dir}."
        exit 1 # Encerra o script com erro
    fi

    echo "  Build concluído. Realizando push da imagem para o Docker Hub..."

    # Executa o push da imagem para o Docker Hub
    docker push ${DOCKER_USERNAME}/${repo_name}:${TAG}

    # Verifica se o comando docker push foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Erro: Falha no push da imagem para o serviço ${service_dir}."
        exit 1 # Encerra o script com erro
    fi

    echo "Imagem ${DOCKER_USERNAME}/${repo_name}:${TAG} construída e enviada para o Docker Hub com sucesso."
}

# Função para atualizar a tag da imagem em um manifesto YAML do Kubernetes
update_kubernetes_manifest() {
    local k8s_manifest_file=$1 # Caminho completo para o arquivo YAML (ex: "k8s/backend/deployment.yaml")
    local repo_name=$2           # Nome do repositório Docker Hub (ex: "seu_repo_backend")

    echo "--- Atualizando a tag da imagem no manifesto Kubernetes: ${k8s_manifest_file} ---"

    # Usa 'sed' para encontrar a linha 'image: <usuario>/<repo>:.*' e substitui por ':nova_tag'
    # Importante: O nome da imagem no seu arquivo YAML DEVE seguir o padrão 'image: seu_dockerhub_username/seu_repo_nome:latest'
    # para que o 'sed' possa encontrar e substituir corretamente.
    sed -i "s|image: ${DOCKER_USERNAME}/${repo_name}:.*|image: ${DOCKER_USERNAME}/${repo_name}:${TAG}|g" "${k8s_manifest_file}"

    # Verifica se o comando sed foi bem-sucedido
    if [ $? -ne 0 ]; then
        echo "Erro: Falha ao atualizar a tag da imagem no arquivo ${k8s_manifest_file}."
        exit 1 # Encerra o script com erro
    fi

    echo "  Tag da imagem em ${k8s_manifest_file} atualizada para: ${TAG}."
}

# --- Execução Principal do Pipeline ---

echo "Iniciando o Pipeline de CI/CD para o ambiente de Produção..."

# Etapa 1: Processamento do Backend
build_and_push "backend" "${REPO_BACKEND}"
update_kubernetes_manifest "k8s/backend/deployment.yaml" "${REPO_BACKEND}"
update_kubernetes_manifest "k8s/cronjob/cronjob.yaml" "${REPO_BACKEND}" # O CronJob usa a mesma imagem do backend

# Etapa 2: Processamento do Frontend
build_and_push "frontend" "${REPO_FRONTEND}"
update_kubernetes_manifest "k8s/frontend/deployment.yaml" "${REPO_FRONTEND}"

echo "Pipeline de CI/CD concluído com sucesso! Manifestos Kubernetes atualizados com as novas tags."
```

**Permissões do Script:**
Antes de executar o script, é necessário garantir que ele possua permissões de execução:

```bash
chmod +x scripts/deploy.sh
```

#### Execução do Pipeline

1.  **Ajuste do script `deploy.sh`**: Abra o arquivo `scripts/deploy.sh` e substitua os placeholders `seu_dockerhub_username`, `seu_repo_backend` e `seu_repo_frontend` pelos valores reais do Docker Hub.
2.  **Execução do script a partir da raiz do projeto**:
    ```bash
    ./scripts/deploy.sh
    ```
    Este script automatizará os seguintes passos:
      * Construção da imagem Docker do backend, tagueamento com uma tag baseada em timestamp e push para o repositório no Docker Hub.
      * Atualização do `k8s/backend/deployment.yaml` e `k8s/cronjob/cronjob.yaml` com a nova tag da imagem do backend.
      * Construção da imagem Docker do frontend, tagueamento e push para o repositório no Docker Hub.
      * Atualização do `k8s/frontend/deployment.yaml` com a nova tag da imagem do frontend.

### Manifestos Kubernetes (`k8s/`)

Os manifestos YAML na pasta `k8s/` definem a infraestrutura e os componentes da aplicação no cluster Kubernetes. Eles são organizados por serviço para facilitar a gestão.

#### ConfigMaps e Secrets

Gerenciam as configurações e dados sensíveis da aplicação de forma segura e flexível, desacoplando-os do código da imagem.

  * **`k8s/config/configmap.yaml`:** Contém variáveis de ambiente não sensíveis, como nomes de hosts de serviços, portas e caminhos de diretório.
    ```yaml
    # k8s/config/configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: app-config
    data:
      DATABASE_HOST: db-service     # Nome do serviço do banco de dados no Kubernetes
      DATABASE_PORT: "5432"
      DATABASE_DBNAME: produtos_db
      UPLOAD_DIR: /app/uploads
      PGHOST: db-service
      PGPORT: "5432"
      PGDATABASE: produtos_db
    ```
  * **`k8s/config/secret.yaml`:** Contém credenciais sensíveis (usuário e senha do banco de dados). Os valores devem ser **base64-encoded**.
      * **Dica:** Para gerar valores em base64, use: `echo -n 'seu_usuario' | base64` e `echo -n 'sua_senha' | base64`.
    <!-- end list -->
    ```yaml
    # k8s/config/secret.yaml
    apiVersion: v1
    kind: Secret
    metadata:
      name: app-secret
    type: Opaque # Tipo genérico para dados arbitrários
    data:
      DATABASE_USER: <base64_do_seu_usuario_db> # Ex: echo -n 'postgres' | base64 -> cG9zdGdyZXM=
      DATABASE_PASS: <base64_da_sua_senha_db>  # Ex: echo -n 'minhasenha' | base64 -> bWluaGFzZW5oYQ==
      PGUSER: <base64_do_seu_usuario_db>
      PGPASSWORD: <base64_da_sua_senha_db>
    ```

#### Persistent Volumes e Persistent Volume Claims (PV/PVC)

Essenciais para garantir a persistência dos dados, assegurando que informações críticas (como dados do PostgreSQL e arquivos de upload) não sejam perdidas, mesmo em caso de reinício ou recriação dos pods.

  * **`k8s/db/pvc.yaml` (PVC para o Banco de Dados):**
    ```yaml
    # k8s/db/pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: postgres-pv-claim
    spec:
      accessModes:
        - ReadWriteOnce # Permite que o volume seja montado como leitura/escrita por um único nó.
      resources:
        requests:
          storage: 5Gi # Solicita 5 Gigabytes de armazenamento.
    ```
  * **`k8s/backend/uploads-pvc.yaml` (PVC para Uploads do Backend):**
    ```yaml
    # k8s/backend/uploads-pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: uploads-pv-claim
    spec:
      accessModes:
        - ReadWriteMany # Pode ser montado como leitura/escrita por múltiplos nós (se suportado pelo provisionador).
      resources:
        requests:
          storage: 1Gi # Solicita 1 Gigabyte de armazenamento.
    ```
    *OBS:* O `ReadWriteMany` pode exigir um provisionador de volume específico (como NFS, EFS em AWS, etc.) em seu cluster Kubernetes para funcionar. Em ambientes locais como Minikube, `ReadWriteOnce` é o modo de acesso mais comumente suportado por padrão para volumes locais.

#### Deployments (Backend, Frontend e Database)

Os Deployments definem o estado desejado para um conjunto de pods, incluindo qual imagem usar, a quantidade de réplicas, a alocação de recursos (CPU/Memória) e as importantes probes de saúde (Liveness e Readiness).

  * **`k8s/db/deployment.yaml` (Deployment do PostgreSQL):**

    ```yaml
    # k8s/db/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: db-deployment
      labels:
        app: db
    spec:
      replicas: 1 # Um único pod para o banco de dados
      selector:
        matchLabels:
          app: db
      template:
        metadata:
          labels:
            app: db
        spec:
          containers:
            - name: postgres
              image: postgres:15 # Imagem Docker oficial do PostgreSQL
              ports:
                - containerPort: 5432
              envFrom: # Carrega variáveis do ConfigMap e Secret
                - configMapRef:
                    name: app-config
                - secretRef:
                    name: app-secret
              resources: # Definição de recursos (request e limit)
                requests:
                  cpu: "250m" # 0.25 vCPU
                  memory: "512Mi"
                limits:
                  cpu: "500m" # 0.5 vCPU
                  memory: "1Gi"
              volumeMounts: # Monta o volume persistente e o script de inicialização
                - name: postgres-storage
                  mountPath: /var/lib/postgresql/data # Caminho padrão de dados do PostgreSQL
                - name: initdb-scripts-volume
                  mountPath: /docker-entrypoint-initdb.d/ # Diretório onde o PostgreSQL espera scripts de inicialização
          volumes: # Vincula o PVC e o ConfigMap que contém o script init_db.sql
            - name: postgres-storage
              persistentVolumeClaim:
                claimName: postgres-pv-claim
            - name: initdb-scripts-volume
              configMap:
                name: initdb-script-cm # Referência ao ConfigMap que será criado para o init_db.sql
                items:
                  - key: init.sql # A chave no ConfigMap
                    path: init.sql # O nome do arquivo no volume montado
    ```

    *OBS:* É necessário criar um `ConfigMap` específico para o script de inicialização do banco de dados (`init_db.sql`), se ele for utilizado para configurar o esquema ou inserir dados iniciais:

    ```yaml
    # k8s/db/initdb-configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: initdb-script-cm
    data:
      init.sql: | # Use '|' para inserir o conteúdo completo do seu arquivo `database/scripts/init_db.sql` aqui
        CREATE DATABASE IF NOT EXISTS produtos_db;
        -- Exemplo: CREATE TABLE IF NOT EXISTS produtos (id SERIAL PRIMARY KEY, nome VARCHAR(255));
        -- Adicione todo o seu SQL de inicialização aqui
    ```

  * **`k8s/backend/deployment.yaml` (Deployment do Backend):**

    ```yaml
    # k8s/backend/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: backend-deployment
      labels:
        app: backend
    spec:
      replicas: 3 # Número mínimo de pods (será gerenciado pelo HPA)
      selector:
        matchLabels:
          app: backend
      template:
        metadata:
          labels:
            app: backend
        spec:
          containers:
            - name: backend
              # A tag da imagem será atualizada automaticamente pelo script de CI/CD
              image: usuario-a-ser-utilizado/seu_repo_backend:latest # Ex: joaodocker/my-backend:v1.0.0
              ports:
                - containerPort: 8081
              envFrom: # Carrega variáveis do ConfigMap e Secret
                - configMapRef:
                    name: app-config
                - secretRef:
                    name: app-secret
              resources: # Definição de recursos (request e limit) para o pod
                requests:
                  cpu: "200m" # Solicita 0.2 vCPU
                  memory: "256Mi" # Solicita 256 MiB de memória
                limits:
                  cpu: "500m" # Limite de 0.5 vCPU
                  memory: "512Mi" # Limite de 512 MiB de memória
              livenessProbe: # Verifica se o container está saudável (vivo)
                httpGet:
                  path: /health # Endpoint de healthcheck (DEVE ser implementado no FastAPI)
                  port: 8081
                initialDelaySeconds: 15 # Espera 15s antes da primeira checagem
                periodSeconds: 20     # Checa a cada 20s
                timeoutSeconds: 5     # Timeout de 5s para a checagem
                failureThreshold: 3   # 3 falhas seguidas para considerar o pod não saudável
              readinessProbe: # Verifica se o container está pronto para receber tráfego
                httpGet:
                  path: /ready # Endpoint de readiness (DEVE ser implementado no FastAPI)
                  port: 8081
                initialDelaySeconds: 5 # Espera 5s antes da primeira checagem
                periodSeconds: 10     # Checa a cada 10s
                timeoutSeconds: 3     # Timeout de 3s para a checagem
                failureThreshold: 3   # 3 falhas seguidas para considerar o pod não pronto
              volumeMounts: # Monta o volume de uploads
                - name: uploads-storage
                  mountPath: /app/uploads
          volumes: # Vincula o PVC para uploads
            - name: uploads-storage
              persistentVolumeClaim:
                claimName: uploads-pv-claim
    ```

    *OBS:* É **altamente recomendado** implementar os endpoints `/health` e `/ready` no FastAPI para que as probes funcionem corretamente e o Kubernetes possa gerenciar a saúde e disponibilidade do aplicativo de forma eficaz.

  * **`k8s/frontend/deployment.yaml` (Deployment do Frontend):**

    ```yaml
    # k8s/frontend/deployment.yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: frontend-deployment
      labels:
        app: frontend
    spec:
      replicas: 3 # Número mínimo de pods (será gerenciado pelo HPA)
      selector:
        matchLabels:
          app: frontend
      template:
        metadata:
          labels:
            app: frontend
        spec:
          containers:
            - name: frontend
              # A tag da imagem será atualizada automaticamente pelo script de CI/CD
              image: usuario-a-ser-utilizado/seu_repo_frontend:latest # Ex: joaodocker/my-frontend:v1.0.0
              ports:
                - containerPort: 80
              resources: # Definição de recursos (request e limit)
                requests:
                  cpu: "100m"
                  memory: "128Mi"
                limits:
                  cpu: "250m"
                  memory: "256Mi"
              livenessProbe: # Probes básicas para o Nginx (servindo o frontend estático)
                httpGet:
                  path: /
                  port: 80
                initialDelaySeconds: 10
                periodSeconds: 15
                timeoutSeconds: 3
                failureThreshold: 3
              readinessProbe:
                httpGet:
                  path: /
                  port: 80
                initialDelaySeconds: 5
                periodSeconds: 10
                timeoutSeconds: 2
                failureThreshold: 2
    ```

#### Services (Backend, Frontend e Database)

Os Services são a abstração que permite a comunicação entre os pods e a exposição das aplicações dentro ou fora do cluster Kubernetes. Eles fornecem um IP estável e balanceamento de carga para um conjunto de pods.

  * **`k8s/db/service.yaml` (Service do PostgreSQL):**

    ```yaml
    # k8s/db/service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: db-service # Este nome (db-service) será usado como DATABASE_HOST no ConfigMap do backend
      labels:
        app: db
    spec:
      selector:
        app: db # Seleciona os pods com o label 'app: db'
      ports:
        - protocol: TCP
          port: 5432 # Porta que o serviço expõe internamente no cluster
          targetPort: 5432 # Porta que o container PostgreSQL escuta
      clusterIP: None # Headless Service, permite DNS direto para os pods do StatefulSet (ou para o único pod do Deployment)
    ```

    *OBS:* Um `clusterIP: None` (Headless Service) é uma boa prática para bancos de dados com um único pod ou StatefulSets, pois permite que clientes se conectem diretamente aos IPs dos pods, e não a um IP virtual de um balanceador de carga.

  * **`k8s/backend/service.yaml` (Service do Backend):**

    ```yaml
    # k8s/backend/service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: backend-service
      labels:
        app: backend
    spec:
      selector:
        app: backend
      ports:
        - protocol: TCP
          port: 8081 # Porta que o serviço expõe (para o frontend e potencial Ingress)
          targetPort: 8081 # Porta que o container backend escuta
      type: ClusterIP # Acessível apenas dentro do cluster Kubernetes.
    ```

    *Para expor o backend à internet, normalmente seria utilizado um Ingress Controller (preferencial) ou, em testes, um `LoadBalancer` (se o cluster o suportar) ou `NodePort`.*

  * **`k8s/frontend/service.yaml` (Service do Frontend):**

    ```yaml
    # k8s/frontend/service.yaml
    apiVersion: v1
    kind: Service
    metadata:
      name: frontend-service
      labels:
        app: frontend
    spec:
      selector:
        app: frontend
      ports:
        - protocol: TCP
          port: 8080 # Porta que o serviço expõe
          targetPort: 80 # Porta que o container Nginx (frontend) escuta
      type: LoadBalancer # Tipo de serviço para expor o frontend à internet.
    ```

    *OBS:* Em ambientes de produção em nuvem, `LoadBalancer` provisiona um balanceador de carga externo. Em Minikube, ele mapeará para um `NodePort` que pode ser acessado via `minikube service frontend-service --url`. Para roteamento avançado (baseado em domínio, caminho, SSL/TLS), um `Ingress Controller` (como Nginx Ingress) e recursos `Ingress` são a abordagem mais escalável e eficiente.

#### Horizontal Pod Autoscaler (HPA)

O HPA é um recurso do Kubernetes que automaticamente escala o número de pods em um Deployment (ou StatefulSet) com base em métricas de utilização (como CPU ou memória).

  * **`k8s/backend/hpa.yaml`:**
    ```yaml
    # k8s/backend/hpa.yaml
    apiVersion: autoscaling/v2 # ou autoscaling/v1 para clusters mais antigos
    kind: HorizontalPodAutoscaler
    metadata:
      name: backend-hpa
    spec:
      scaleTargetRef: # Referencia o Deployment que o HPA irá escalar
        apiVersion: apps/v1
        kind: Deployment
        name: backend-deployment
      minReplicas: 3 # Número mínimo de pods que o Deployment deve manter
      maxReplicas: 6 # Número máximo de pods que o Deployment pode escalar
      metrics: # Define as métricas para o escalonamento
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 70 # Escala quando o uso médio de CPU dos pods atinge 70%
    ```
  * **`k8s/frontend/hpa.yaml`:**
    ```yaml
    # k8s/frontend/hpa.yaml
    apiVersion: autoscaling/v2 # ou autoscaling/v1
    kind: HorizontalPodAutoscaler
    metadata:
      name: frontend-hpa
    spec:
      scaleTargetRef:
        apiVersion: apps/v1
        kind: Deployment
        name: frontend-deployment
      minReplicas: 3
      maxReplicas: 6
      metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 70
    ```
    *OBS:* Para que o HPA funcione, o Metric Server deve estar instalado e rodando no cluster Kubernetes. O Minikube geralmente o habilita por padrão.

#### CronJob

Um CronJob cria Jobs periodicamente em um agendamento definido (formato cron). É ideal para tarefas de manutenção, relatórios, backups, etc.

  * **`k8s/cronjob/cronjob.yaml`:**
    ```yaml
    # k8s/cronjob/cronjob.yaml
    apiVersion: batch/v1
    kind: CronJob
    metadata:
      name: cleanup-csv-cronjob
    spec:
      schedule: "*/5 * * * *" # Agenda a execução a cada 5 minutos (formato cron)
      jobTemplate: # Template para o Job que será criado pelo CronJob
        spec:
          template:
            spec:
              containers:
                - name: cleanup-csv
                  # A imagem utilizada é a mesma do backend, pois o script `cron.py` está contido nela.
                  image: usuario-a-ser-utilizado/seu_repo_backend:latest # Ex: joaodocker/my-backend:v1.0.0
                  command: ["bash", "cron.sh"] # O comando para executar o script Python via shell
                  envFrom: # Carrega variáveis de ambiente necessárias do ConfigMap e Secret
                    - configMapRef:
                        name: app-config
                    - secretRef:
                        name: app-secret
                  volumeMounts: # Monta o volume de uploads para que o CronJob possa acessar os CSVs
                    - name: uploads-storage
                      mountPath: /app/uploads
              volumes: # Vincula o Persistent Volume Claim de uploads
                - name: uploads-storage
                  persistentVolumeClaim:
                    claimName: uploads-pv-claim
              restartPolicy: OnFailure # Se o pod do Job falhar, ele será reiniciado
    ```

### Deploy no Kubernetes

Após ter as imagens Docker necessárias publicadas no Docker Hub e os manifestos Kubernetes atualizados com as tags corretas (pelo script `deploy.sh`), a aplicação pode ser implantada no cluster.

1.  **Navegação até a pasta de manifestos Kubernetes (`k8s/`):**

    ```bash
    cd /caminho/do/seu/projeto/devops-pleno-01726-2025-603.763.273-16-main/k8s/
    ```

    *É importante estar neste diretório para que os comandos `kubectl apply -f .` funcionem corretamente. Alternativamente, é possível usar os caminhos absolutos como no tópico "Passos de Implantação" da versão 2, mas a navegação é ideal.*

2.  **Aplicação dos manifestos do Kubernetes na ordem correta:**

      * A ordem de aplicação é crucial devido às dependências entre os recursos.
      * **Remoção de recursos antigos (se necessário):** Se for necessária uma reinstalação limpa, os recursos existentes podem ser deletados primeiro.
        ```bash
        # CUIDADO: Isso irá deletar todos os recursos definidos na pasta k8s/ do seu cluster!
        # Use com cautela em ambientes que não sejam de desenvolvimento.
        # kubectl delete -f . -n default --ignore-not-found=true
        ```
      * **Aplicação dos novos recursos:**
        ```bash
        # 1. ConfigMaps e Secrets (geralmente aplicados primeiro, pois outros recursos dependem deles)
        kubectl apply -f ./config/configmap.yaml -n default
        kubectl apply -f ./config/secret.yaml -n default
        kubectl apply -f ./db/initdb-configmap.yaml # Se o ConfigMap para o script init.sql foi criado

        # 2. Persistent Volume Claims (PVCs) - solicitam o armazenamento persistente
        kubectl apply -f ./db/pvc.yaml -n default
        kubectl apply -f ./backend/uploads-pvc.yaml -n default

        # 3. Deployments (Backend, Frontend, Database) - criam e gerenciam os pods
        kubectl apply -f ./db/deployment.yaml -n default
        kubectl apply -f ./backend/deployment.yaml -n default
        kubectl apply -f ./frontend/deployment.yaml -n default

        # 4. Services - expõem os Deployments para comunicação
        kubectl apply -f ./db/service.yaml -n default
        kubectl apply -f ./backend/service.yaml -n default
        kubectl apply -f ./frontend/service.yaml -n default

        # 5. Horizontal Pod Autoscalers (HPAs) - para escalabilidade automática
        kubectl apply -f ./backend/hpa.yaml -n default
        kubectl apply -f ./frontend/hpa.yaml -n default

        # 6. CronJob - para tarefas agendadas
        kubectl apply -f ./cronjob/cronjob.yaml -n default
        ```

3.  **Retorno para a raiz do projeto após o deploy:**

    ```bash
    cd ../
    ```

### Comandos Úteis do Kubernetes

Estes comandos são essenciais para monitorar e depurar a aplicação no cluster Kubernetes:

  * **Listar todos os pods no namespace padrão (`default`):**
    ```bash
    kubectl get pods -n default
    ```
  * **Listar todos os serviços:**
    ```bash
    kubectl get svc -n default
    ```
  * **Listar todos os deployments:**
    ```bash
    kubectl get deployments -n default
    ```
  * **Listar todos os HPAs:**
    ```bash
    kubectl get hpa -n default
    ```
  * **Listar todas as CronJobs:**
    ```bash
    kubectl get cronjob -n default
    ```
  * **Listar todos os Persistent Volume Claims (PVCs):**
    ```bash
    kubectl get pvc -n default
    ```
  * **Verificar logs de um pod específico (substitua `<pod-name>` pelo nome real do pod):**
    ```bash
    kubectl logs <pod-name> -n default -f # O '-f' permite seguir os logs em tempo real
    ```
  * **Descrever um recurso para obter detalhes completos e eventos (útil para depuração):**
    ```bash
    kubectl describe pod <pod-name> -n default
    kubectl describe deployment backend-deployment -n default
    kubectl describe service frontend-service -n default
    ```
  * **Deletar todos os recursos definidos em um diretório (CUIDADO\!):**
    ```bash
    # Primeiro, navegue para o diretório k8s/
    cd k8s/
    kubectl delete -f . -n default
    cd ..
    ```
  * **Reiniciar um deployment (força a recriação dos pods):**
    ```bash
    kubectl rollout restart deployment/backend-deployment -n default
    ```

## 5\. Monitoramento e Verificação

Após a implantação dos manifestos, é crucial monitorar e verificar o funcionamento de todos os componentes da aplicação no cluster.

  * **Verificação do status dos pods:**
    ```bash
    kubectl get pods -n default
    ```
    Todos os pods dos Deployments devem estar no status `1/1 READY` e `Running`. Os pods do CronJob aparecerão como `Completed` após a execução bem-sucedida da tarefa.
    *Exemplo de saída esperada (nomes dos pods serão diferentes):*
    ```
    NAME                                  READY   STATUS      RESTARTS   AGE
    backend-75d9f77fbd-9z9jz              1/1     Running     0          15m
    frontend-5b4d6c7b8f-abcde             1/1     Running     0          14m
    db-deployment-9a8b7c6d5e-vwxyz        1/1     Running     0          16m
    cleanup-csv-cronjob-170720251030-hijk 0/1     Completed   0          2m
    ```
  * **Acesso ao Frontend via Minikube:**
    Se o Minikube estiver sendo usado e o serviço `frontend-service` for do tipo `LoadBalancer`:
    ```bash
    minikube service frontend-service --url
    ```
    Este comando fornecerá a URL para acessar a aplicação no navegador. Copie e cole no seu browser.
  * **Teste da comunicação Frontend-Backend:**
    Navegue pela aplicação Frontend e verifique se as requisições para o Backend (ex: listagem de produtos, upload de arquivos) estão funcionando corretamente.
  * **Teste da comunicação Backend-PostgreSQL:**
    Realize operações que envolvam o banco de dados (ex: criar, ler, atualizar, deletar dados via API do Backend) para confirmar que o Backend consegue se conectar e interagir com o PostgreSQL.
  * **Monitoramento de logs:**
    Utilize `kubectl logs <nome-do-pod> -n default -f` para observar os logs dos pods do `backend`, `frontend` e `db-deployment` em tempo real. Isso é crucial para identificar erros ou problemas.
  * **Verificação da execução do CronJob:**
    1.  Liste os Jobs criados pelo CronJob:
        ```bash
        kubectl get jobs -n default
        ```
    2.  Obtenha o nome do pod do Job mais recente (ex: `cleanup-csv-cronjob-XXXXXXXX-xxxxx`):
        ```bash
        kubectl get pods -l job-name=<nome-do-job> -n default
        ```
    3.  Verifique os logs do pod do Job para confirmar se a tarefa foi executada com sucesso:
        ```bash
        kubectl logs <nome-do-pod-do-job> -n default
        ```
  * **Observação do escalonamento automático (HPA):**
    Simule carga no Backend (com ferramentas como `hey`, `locust` ou `wrk`) e observe o `kubectl get hpa` para ver se o número de pods do Backend e Frontend escala automaticamente conforme a utilização da CPU aumenta.

## 6\. Resolução de Problemas Comuns e Desafios Encontrados

Durante o processo de desenvolvimento e implantação deste projeto, alguns desafios e problemas comuns foram encontrados, que são típicos em ambientes Kubernetes. As soluções e diagnósticos detalhados abaixo podem auxiliar na depuração de problemas similares.

### Erros de Pull de Imagem (`ErrImagePull` / `ImagePullBackOff`)

  * **Problema:** Pods travam no estado `ErrImagePull` ou `ImagePullBackOff` com mensagens como `manifest unknown`, `not found`, ou `unauthorized`. Isso significa que o Kubernetes não consegue encontrar a imagem no registro (Docker Hub) ou não tem permissão para puxá-la.
  * **Diagnóstico:**
      * **Tag Incorreta/Inexistente:** A tag da imagem especificada no `deployment.yaml` não existe no repositório do Docker Hub, ou o nome do repositório/usuário está incorreto.
      * **Nome da Imagem no Dockerfile vs. Deployment:** As tags das imagens construídas localmente (`devops-pleno-...`) não correspondiam ao nome de repositório esperado no `deployment.yaml` (`usuario-a-ser-utilizado/backend:latest`).
      * **Problema de Autenticação:** A imagem está em um repositório privado e o Kubernetes não possui credenciais para acessá-lo (não aplicável para este projeto se o repo for público).
      * **Incompatibilidade de Arquitetura:** A imagem foi construída para uma arquitetura diferente daquela em que o nó do Kubernetes (Minikube) está rodando (ex: imagem ARM64 em Minikube AMD64).
  * **Solução:**
    1.  **Verificação da Tag e do Nome do Repositório:** Certifique-se de que o nome da imagem no `deployment.yaml` (`image: usuario-a-ser-utilizado/seu_repo_backend:latest`) corresponde exatamente ao que foi tagueado e enviado para o Docker Hub.
    2.  **Retag e Push Correto:** Se a imagem local tiver uma tag diferente, retague-a e faça o push novamente para o Docker Hub com a tag correta e o nome de usuário completo:
        ```bash
        docker tag devops-pleno-01726-2025-603763273-16-main-backend:latest usuario-a-ser-utilizado/seu_repo_backend:latest
        docker push usuario-a-ser-utilizado/seu_repo_backend:latest
        # Repita para o frontend e qualquer outra imagem necessária
        ```
    3.  **Construção com Arquitetura Específica:** Reconstrua a imagem explicitamente para a arquitetura alvo do cluster Kubernetes (Minikube geralmente é `linux/amd64`):
        ```bash
        docker build --platform linux/amd64 -t usuario-a-ser-utilizado/seu_repo_backend:latest .
        docker push usuario-a-ser-utilizado/seu_repo_backend:latest
        ```

### Erro `unsupported media type application/vnd.in-toto+json`

  * **Problema:** Um erro específico que ocorreu durante o push da imagem do backend, mesmo após corrigir as tags, indicando `unsupported media type application/vnd.in-toto+json`.
  * **Diagnóstico:** Este erro pode sugerir uma incompatibilidade no formato da imagem Docker, problemas relacionados a assinaturas de conteúdo (Docker Content Trust) ou artefatos de build incompletos/corrompidos. A causa mais comum está relacionada à construção da imagem para uma arquitetura inesperada ou problemas de metadados da imagem.
  * **Solução:** Para contornar este problema durante o desenvolvimento, foi adotada a reconstrução da imagem do backend, especificando a plataforma `linux/amd64` e desativando temporariamente o `DOCKER_CONTENT_TRUST`.
    ```bash
    export DOCKER_CONTENT_TRUST=0 # Desativa temporariamente a verificação de confiança do conteúdo Docker
    docker build --platform linux/amd64 -t usuario-a-ser-utilizado/seu_repo_backend:latest .
    docker push usuario-a-ser-utilizado/seu_repo_backend:latest
    ```
    *OBS:* Desativar o Docker Content Trust em ambientes de produção não é uma prática de segurança recomendada, mas é útil para depuração e testes. Em produção, a investigação da causa raiz da falha de assinatura ou o uso de métodos de confiança apropriados é essencial.

### Erro `Unexpected args` no `kubectl apply`

  * **Problema:** Ao tentar aplicar os manifestos YAML, comandos como `kubectl apply -f /mnt/c/Users/Hermanio Santana/...` resultavam em `error: Unexpected args: [Santana/Documents/...]`.
  * **Diagnóstico:** O shell estava interpretando os espaços no caminho do arquivo (ex: "Hermanio Santana" no caminho do usuário no Windows) como separadores de argumentos para o `kubectl`, em vez de parte do caminho do arquivo.
  * **Solução:** Sempre coloque o caminho completo do arquivo entre **aspas duplas** quando houver espaços no caminho. A forma mais comum e recomendada é navegar para o diretório `k8s/` e usar caminhos relativos ao aplicar os manifestos, o que evita problemas com espaços.
    ```bash
    # Solução 1: Usando aspas duplas (se estiver na raiz do projeto)
    kubectl apply -f "/caminho/do/seu/projeto/k8s/backend/deployment.yaml" -n default

    # Solução 2 (Recomendada): Navegue para o diretório k8s/ e use caminhos relativos
    cd /caminho/do/seu/projeto/k8s/
    kubectl apply -f ./backend/deployment.yaml -n default
    # ... e depois volte para a raiz com cd ../
    ```

### Backend 0/1 READY (Probes de Saúde)

  * **Problema:** Após a imagem do backend ser puxada com sucesso e o contêiner iniciar, o pod permanecia no status `0/1 READY`, mesmo que a aplicação parecesse estar rodando internamente.
  * **Diagnóstico:** A análise dos logs do pod do backend (`kubectl logs <pod-backend>`) revelou que o aplicativo Uvicorn estava iniciando e rodando na porta 8081, mas as requisições para o endpoint `/health` (usado pelas Liveness e Readiness Probes do Kubernetes) estavam retornando `404 Not Found`. Isso indicava que a aplicação FastAPI não possuía ou não respondia a esse endpoint de saúde configurado no `deployment.yaml`.
  * **Solução Adotada (Temporária para este projeto):** Para garantir que o pod do backend atingisse o status `1/1 READY` e permitisse o prosseguimento da implantação e testes, as seções `livenessProbe` e `readinessProbe` foram **temporariamente removidas** do arquivo `k8s/backend/deployment.yaml`.
    *Exemplo de alteração no `k8s/backend/deployment.yaml` (linhas que foram comentadas/removidas):*
    ```yaml
    containers:
      - name: backend
        image: usuario-a-ser-utilizado/backend:latest
        ports:
          - containerPort: 8081
        # ... outras configurações ...
        # livenessProbe: # <-- ESTA SEÇÃO FOI REMOVIDA TEMPORARIAMENTE
        #   httpGet:
        #     path: /health
        #     port: 8081
        #   initialDelaySeconds: 15
        #   periodSeconds: 20
        #   timeoutSeconds: 5
        #   failureThreshold: 3
        # readinessProbe: # <-- ESTA SEÇÃO FOI REMOVIDA TEMPORARIAMENTE
        #   httpGet:
        #     path: /ready # ou /health, dependendo da sua implementação
        #     port: 8081
        #   initialDelaySeconds: 5
        #   periodSeconds: 10
        #   timeoutSeconds: 3
        #   failureThreshold: 3
    ```
  * **Implicações da Solução Temporária:** Embora a remoção das probes resolva o problema imediato do pod `0/1 READY`, ela **compromete a robustez e a confiabilidade da aplicação em um ambiente de produção**. Sem Liveness Probes, o Kubernetes não consegue detectar e reiniciar automaticamente um contêiner travado. Sem Readiness Probes, o Kubernetes pode direcionar tráfego para um pod que ainda não está pronto para recebê-lo, causando erros para os usuários.
  * **Próximo Passo Essencial:** A **solução ideal e recomendada** é **adicionar e implementar os endpoints `/health` e `/ready` no código da aplicação backend (FastAPI)** que retornem `HTTP 200 OK` quando a aplicação estiver saudável, inicializada e pronta para receber tráfego. Após a implementação, as probes **devem ser reativadas** no `k8s/backend/deployment.yaml` para aproveitar os recursos de autorrecuperação do Kubernetes.

## 7\. Considerações Finais e Próximos Passos

Este projeto demonstra conteinerização e orquestração de uma aplicação fullstack em um ambiente Kubernetes. Atualmente, o Frontend, PostgreSQL e o CronJob estão operacionais e no status `Running`/`Completed`. O Backend também está `Running` e `1/1 READY` (com a observação sobre as probes de saúde).

### Próximos Passos Essenciais para Aprimoramento:

1.  **Implementar Endpoints `/health` e `/ready` no Backend:** Esta é a prioridade máxima para restaurar a robustez do Backend. Adicione estes endpoints em seu FastAPI e reative as probes no `k8s/backend/deployment.yaml`.
2.  **Teste de Funcionalidade End-to-End Abrangente:** Após o deploy, a validação de todas as funcionalidades da aplicação é crucial, garantindo que a comunicação entre Frontend, Backend e PostgreSQL esteja perfeita, e que a lógica de negócios e persistência de dados funcionem conforme o esperado.
3.  **Configurar Acesso Externo Otimizado:** A exploração da configuração de um `Ingress Controller` (como Nginx Ingress) e recursos `Ingress` é recomendada para gerenciar o acesso externo ao Frontend e, se necessário, ao Backend. Isso oferece roteamento baseado em domínio/caminho, terminação SSL/TLS e balanceamento de carga de forma mais eficiente do que múltiplos `LoadBalancer` Services.
4.  **Validação do CronJob:** Confirmar que o `CronJob` (`cleanup-csv-cronjob`) executa sua função de limpeza de forma eficaz e no intervalo esperado, monitorando seus logs.
5.  **Refinamento da Alocação de Recursos:** Com base em testes de carga e monitoramento, o ajuste dos `requests` e `limits` de CPU e Memória nos manifestos Kubernetes é fundamental para otimizar o uso de recursos e o desempenho.
6.  **Implementar Observabilidade Completa:** A adição de ferramentas de monitoramento (ex: Prometheus e Grafana para métricas) e sistemas de log centralizados (ex: ELK Stack, Loki) é essencial para obter uma visibilidade completa do comportamento da aplicação e da infraestrutura.
7.  **Aprimorar a Segurança:**
      * Considerar o uso de `ImagePullSecrets` para puxar imagens de repositórios Docker privados de forma segura.
      * Implementar `Network Policies` para controlar o tráfego de rede entre os pods no cluster, aumentando a segurança.
      * Revisar e aplicar as melhores práticas de segurança para o PostgreSQL e outros componentes.
8.  **Automar o Deploy com Ferramentas de CI/CD Reais:** A integração do processo de build, push e deploy em uma ferramenta de CI/CD como Jenkins, GitLab CI, GitHub Actions, CircleCI, etc., é um próximo passo para um fluxo de trabalho de entrega contínua totalmente automatizado.
