# Consulta de Pessoas - Full Stack

Aplicação Full Stack desenvolvida para consulta de dados cadastrais
por CPF, nome e similaridade de nome.

## Estrutura do projeto
```
aplicacao-servidor-consulta/
├── backend/                        
│   ├── routes/                     # armazena os endpoints                     
│   │   └── health.py               # enpoint de verificação da api e conexão com o banco    
│   ├── tests                       # testes automatizados
│   ├── db.py                       # centraliza conexão com o PostreSQL
│   └── server.py                   # inicializa servidor Flask 
│ 
├── db/                             
│   ├── clean_data/                 # armazena os dados limpos
│   │   └── log.txt                 # log dos dados
│   ├── importar_dados.py           # importa os dados para o banco
│   ├── preparar_dados.py           # prepara e limpa os dados
│   └── init.sql                    # sql para inicialização e estruturação do banco
│ 
├── frontend/
|
├── .env
├── .gitignore
├── docker-compose.yml
├── requirements.txt
└── README.md
```
## Execução

Siga os passos abaixo para configurar e executar o banco de dados e a API.

### 1. Configurar as variáveis de ambiente

Na raiz do projeto, crie o arquivo `.env` com as configurações de conexão com o PostgreSQL.

```dotenv
DB_HOST=localhost
DB_PORT=5433
DB_NAME=nome_do_banco
DB_USER=usuario
DB_PASSWORD=senha
```

### 2. Instalação das dependências
Na raiz do projeto execute:

```
pip install -r requirements.txt
```

### 3. Banco de dados
O projeto utiliza PostgreSQL como banco de dados relacional. Sua configuração de execução está definida no Docker Compose, e os scripts Python são responsáveis pela preparação e importação dos dados

Na raiz do projeto, entre na pasta db/:
```
cd db
```

Inicie o banco de dados:
```
docker compose up -d
```

Verifique se o container está em execução:
```
docker compose ps
```

Adicione os arquivos de dados limpos ao diretório clean_data:
```
db/clean_data/aposentados_limpos.csv
db/clean_data/cargos_limpos.csv
```

Execute o script de importação:
```
python importar_dados.py
```

### 4. Backend
O backend é desenvolvido em Python utilizando Flask para disponibilizar os endpoints da API. A conexão com o PostgreSQL é centralizada no módulo `db.py`

Na raiz do projeto, entre na pasta backend/:
```
cd backend
```

Execute o servidor Flask:
```
python server.py
```

Por padrão, a aplicação estará disponível em:
```
http://127.0.0.1:3000
```

#### Health check 
Com a API em execução, acesse o endereço:
```
http://127.0.0.1:3000/health
```

Reposta de sucesso retorna status `HTTP 200 OK`:
```
{
  "status": "ok",
  "database": "connected"
}
```
Resposta de erro retorna status HTTP `503 Service Unavailable`:
```
{
  "status": "error",
  "database": "disconnected"
}
```

## Tecnologias

- Python
- Flask
- Gunicorn
- Flutter
- PostgreSQL
- Docker
- Docker Compose