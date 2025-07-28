
# Instruções para subir o projeto

Siga as etapas abaixo para configurar o funcionamento do projeto.

## Database

A base de dados é PostgreSQL.

Para inicializar:

- Abra uma nova instância do terminal
- Entre na pasta database: `cd database`
- Execute o script: `./start.sh`

A base deve ser inicializada e já criar a tabela `product.product`.

## Backend

O backend foi desenvolvido na linguagem Python, usando a biblioteca FastAPI.

Para inicializar:

- Abra uma nova instância do terminal
- Entre na pasta backend: `cd backend`
- Crie um ambiente virtual: `python3 -m venv venv_prova`
- Ative o ambiente virtual: `source venv_prova/bin/activate`
- Instale as dependências do projeto: `pip install -r requirements.txt`
- Execute o script: `./start.sh`

Após isso o backend deverá estar acessível pela URL: <http://http://localhost:8081>.

## Cron

A cron executa um código em Python que remove os arquivos *.csv de dentro da pasta de uploads.

Para executar:

- Abra uma nova instância do terminal
- Entre na pasta backend: `cd backend`
- Ative o ambiente virtual: `source venv_prova/bin/activate`
- Execute o script: `./cron.sh`

## Frontend

Para inicializar:

- Abra uma nova instância do terminal
- Entre na pasta frontend: `cd frontend`
- Instale as dependências do projeto: `npm install`
- Inicie o servidor de desenvolvimento: `npm run serve`

Após isso o frontend deverá estar acessível pela URL: <http://http://localhost:8080>.

Para testar a importação de arquivos, existe um arquivo `exemplo.csv` na pasta principal do repositório.
