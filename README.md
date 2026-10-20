# Consulta de Pessoas - Full Stack

Aplicação Full Stack desenvolvida para consulta de dados cadastrais
por cargo, UF, orgão, nome e similaridade de nome.

## Estrutura do projeto

```
aplicacao-servidor-consulta/
<<<<<<< HEAD
├── backend/
│   ├── routes/                     # armazena os endpoints
│   │   └── health.py               # enpoint de verificação da api e conexão com o banco
=======
├── backend/
│   ├── routes/                     # armazena os endpoints
│   │   └── health.py               # enpoint de verificação da api e conexão com o banco
│   │   └── api.py                  # enpoint de busca de servidores
>>>>>>> origin/main
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
│   ├── lib/                        # código-fonte Dart
│   └── pubspec.yam
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

<<<<<<< HEAD

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

=======
O projeto utiliza PostgreSQL como banco de dados relacional. Sua configuração de execução está definida no Docker Compose, e os scripts Python são responsáveis pela preparação e importação dos dados.

Na raiz do projeto, inicie os serviços do PostgreSQL e do backend:

docker compose up -d --build

Verifique se os contêineres estão em execução:

> > > > > > > origin/main

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
python db/importar_dados.py
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

<<<<<<< HEAD

#### Health check

=======
A execução com python server.py é uma alternativa local à execução pelo Docker Compose. Caso o backend já esteja sendo executado no Docker, não é necessário iniciar o servidor Flask separadamente.

#### Health check

> > > > > > > origin/main
> > > > > > > Com a API em execução, acesse o endereço:

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

### 5. Frontend

O frontend foi desenvolvido em Flutter com suporte a Web e Desktop, utilizando Material 3 e arquitetura orientada a funcionalidades (_Feature-First_).

Na raiz do projeto, entre na pasta `frontend/`:

```bash
cd frontend
```

Instale as dependências:

```bash
flutter pub get
```

Execute a aplicação:
Versão Web (Chrome):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Versão Desktop (Windows):

```bash
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

#### Nota: Caso a porta ou o IP da API sejam alterados, basta ajustar o parâmetro --dart-define=API_BASE_URL. Se omitido, o padrão é http://localhost:3000.

Para gerar os binários de produção:

```bash
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:3000
flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

#### Busca de servidores

```
GET /api/servidores?page=x&<filtros>
```

Retorna servidores ativos e aposentados, com paginação.
É recomendado sempre mandar a página e pelo menos um filtro de busca (nome, cargo, uf, orgao ou similar) na requisição.
Se nenhum filtro for mandado (apenas GET /api/servidores), o resultado fica vazio.

| Parâmetro | Descrição                                   | Exemplo                     |
| --------- | ------------------------------------------- | --------------------------- |
| `nome`    | Nome completo (correspondência exata)       | `nome=JOAO DA SILVA`        |
| `cargo`   | Cargo (correspondência exata)               | `cargo=PROFESSOR`           |
| `uf`      | Sigla do estado                             | `uf=SP`                     |
| `orgao`   | Órgão (correspondência exata)               | `orgao=MINISTERIO DA SAUDE` |
| `similar` | Padrão de nome, usando `%` como curinga     | `similar=%25silva%25`       |
| `limit`   | Registros por página (padrão e máximo: 100) | `limit=20`                  |
| `page`    | Número da página (padrão: 1)                | `page=2`                    |

Exemplos:

```
http://127.0.0.1:3000/api/servidores?page=5&uf=SP&limit=80
http://127.0.0.1:3000/api/servidores?page=2&similar=%silva%
```

Exemplo de resposta de sucesso, onde status `HTTP 200 OK`:

```
{
  "data": [
    {
      "nome": "JOAO DA SILVA",
      "cpf": "***.123.456-**",
      "cargo": "PROFESSOR",
      "uf": "SP",
      "orgao": "MINISTERIO DA EDUCACAO",
      "remuneracao": 8500.0
    }
  ],
  "total": 1532
}
```

`total` é a quantidade de registros encontrados com os filtros, considerando todas as páginas.

Resposta de erro retorna status `HTTP 503 Service Unavailable`:

```
{
  "status": "error",
  "message": "Erro ao consultar banco!"
}
```

## Testes automatizados

O projeto utiliza **pytest** para executar testes unitários e de integração da API Flask.

Os testes estão organizados no diretório `backend/tests/`:

- `unit/`: verifica filtros, paginação, validação de parâmetros, proteção contra SQL Injection e tratamento de erros utilizando um banco simulado
- `integration/`: verifica consultas reais ao PostgreSQL, estrutura dos dados, filtros, paginação e requisições concorrentes
- `conftest.py`: contém as configurações compartilhadas pelos testes, incluindo o cliente de testes do Flask e a conexão simulada com o banco

### Executar os testes

Antes de executar os testes de integração, é necessário que o PostgreSQL esteja em funcionamento e contenha os dados importados.

Na raiz do projeto, instale as dependências:

```cmd
pip install -r requirements.txt
```

Entre na pasta do backend:

```cmd
cd backend
```

Execute todos os testes automatizados:

```cmd
python -m pytest tests/ -v -p no:cacheprovider
```

Na execução realizada durante o desenvolvimento, os **21 testes passaram**, sem falhas.

### Testes de carga

Foram realizados testes de carga com requisições HTTP reais ao backend executado com Gunicorn no Docker, utilizando o script `backend/tests/integration/teste_carga_real.py`.

Os testes avaliaram três níveis de concorrência:

| Requisições | Simultâneas | Sucessos | Falhas | Tempo médio |
| ----------- | ----------- | -------- | ------ | ----------- |
| 5           | 2           | 5        | 0      | 0,37 s      |
| 10          | 5           | 10       | 0      | 0,72 s      |
| 20          | 10          | 20       | 0      | 1,27 s      |

Todas as 35 requisições foram atendidas com sucesso nas condições testadas.

Para executar o script de carga, mantenha o backend em funcionamento na porta `3000` e, dentro da pasta `backend`, execute:

```cmd
python tests/integration/teste_carga_real.py
```

Por padrão, o script executa a última configuração habilitada, com 20 requisições e até 10 simultâneas.

Os testes de carga demonstram o comportamento da aplicação nos cenários avaliados, mas não determinam sua capacidade máxima.

Após os testes, uma nova requisição à API retornou HTTP 200, confirmando que o backend continuou respondendo normalmente.

## Execução com Docker e Gunicorn

O projeto utiliza Docker Compose para executar o PostgreSQL e o backend Flask em contêineres separados.

O backend utiliza **Gunicorn** como servidor WSGI, permitindo executar a aplicação Flask sem depender do servidor de desenvolvimento.

### Iniciar os serviços

Com o Docker Desktop em funcionamento e o arquivo `.env` configurado, execute na **raiz do projeto**:

```cmd
docker compose up -d --build
```

Esse comando constrói a imagem do backend e inicia os serviços definidos no `docker-compose.yml`.

Para verificar o estado dos contêineres:

```cmd
docker compose ps
```

Os serviços utilizados são:

| Contêiner            | Função                           | Porta no computador |
| -------------------- | -------------------------------- | ------------------- |
| `servidores-db`      | Banco de dados PostgreSQL        | `5433`              |
| `servidores-backend` | API Flask executada com Gunicorn | `3000`              |

O backend aguarda o PostgreSQL estar saudável antes de iniciar.

### Acessar a API

Após iniciar os contêineres, a API estará disponível em:

```text
http://localhost:3000
```

Para consultar servidores:

```text
http://localhost:3000/api/servidores?uf=RS&limit=5
```

### Configuração do Gunicorn

O arquivo `backend/Dockerfile` configura o Gunicorn com:

- Endereço: `0.0.0.0:3000`
- Workers: `2`
- Timeout por worker: `60 segundos`
- Aplicação: `server:app`

O Gunicorn é iniciado automaticamente quando o contêiner do backend é executado.

### Consultar logs

Para visualizar os logs do backend:

```cmd
docker compose logs backend
```

Para visualizar os logs do PostgreSQL:

```cmd
docker compose logs db-server
```

### Encerrar os serviços

Na raiz do projeto, execute:

```cmd
docker compose down
```

Esse comando encerra e remove os contêineres, preservando o volume de dados do PostgreSQL.

**Atenção:** não utilize `docker compose down -v` se quiser manter os dados armazenados no banco.

## Tecnologias

- Python
- Flask
- Gunicorn
- Flutter
- PostgreSQL
- Docker
- Docker Compose
