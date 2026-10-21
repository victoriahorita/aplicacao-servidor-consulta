# Consulta de Pessoas - Full Stack

Aplicação Full Stack desenvolvida para consulta de servidores públicos ativos e aposentados
por nome, similaridade de nome, cargo, UF e órgão.

## Estrutura do projeto

```
aplicacao-servidor-consulta/
├── backend/
│   ├── routes/                     # armazena os endpoints
│   │   ├── health.py               # endpoint de verificação da API e conexão com o banco
│   │   └── api.py                  # endpoint de busca de servidores
│   ├── tests/                      # testes automatizados
│   ├── db.py                       # centraliza a conexão com o PostgreSQL
│   ├── limitador.py                # limita a quantidade de buscas simultâneas
│   ├── server.py                   # inicializa o servidor Flask
│   └── Dockerfile                  # imagem do backend com Gunicorn
│
├── db/
│   ├── clean_data/                 # armazena os dados limpos
│   │   └── log.txt                 # log dos dados
│   ├── importar_dados.py           # importa os dados para o banco
│   ├── preparar_dados.py           # prepara e limpa os dados
│   └── init.sql                    # SQL de inicialização e estruturação do banco
│
├── frontend/
│   ├── lib/                        # código-fonte Dart
│   ├── pubspec.yaml
│   ├── nginx.conf                  # configuração do servidor web do frontend
│   └── Dockerfile                  # imagem do frontend (build Flutter Web + Nginx)
│
├── .env
├── .gitignore
├── docker-compose.yml
├── requirements.txt
└── README.md
```

## Execução

Siga os passos abaixo para configurar e executar a aplicação completa.

### 1. Configurar as variáveis de ambiente

Na raiz do projeto, crie o arquivo `.env` com as configurações de conexão com o PostgreSQL.

```dotenv
DB_HOST=localhost
DB_PORT=5433
DB_NAME=nome_do_banco
DB_USER=usuario
DB_PASSWORD=senha
```

### 2. Instalar as dependências

O backend no Docker já instala as dependências do `requirements.txt` durante o build da imagem.

A instalação local só é necessária para os scripts executados fora do Docker: preparação e importação dos dados, testes automatizados e execução local do backend. Nesse caso, na raiz do projeto, crie e ative um ambiente virtual e instale as dependências:

```
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Iniciar os serviços

O projeto utiliza PostgreSQL como banco de dados relacional. Sua configuração de execução está definida no Docker Compose, junto com o backend e o frontend, e os scripts Python são responsáveis pela preparação e importação dos dados.

Com o Docker Desktop em funcionamento e o arquivo `.env` configurado, execute na **raiz do projeto**:

```
docker compose up -d --build
```

Esse comando constrói as imagens do backend e do frontend e inicia os serviços definidos no `docker-compose.yml`.

Verifique se os contêineres estão em execução:

```
docker compose ps
```

O primeiro build do frontend pode levar alguns minutos, pois o Flutter é baixado dentro do contêiner.

### 4. Importar os dados

Adicione os arquivos de dados limpos ao diretório `clean_data`:

```
db/clean_data/aposentados_limpos.csv
db/clean_data/cargos_limpos.csv
```

Caso ainda não existam, eles podem ser gerados a partir dos dados brutos com o script `db/preparar_dados.py`.

Na raiz do projeto, execute o script de importação:

```
python db/importar_dados.py
```

O script roda fora do Docker e acessa o banco pela porta `5433`, usando as variáveis do `.env`.

### 5. Acessar a aplicação

| Serviço  | Endereço                |
| -------- | ----------------------- |
| Frontend | `http://localhost:8080` |
| API      | `http://localhost:3000` |

## Endpoints da API

### Health check

```
GET /health
```

Verifica se a API está em execução e se a conexão com o banco está funcionando.

Resposta de sucesso retorna status `HTTP 200 OK`:

```
{
  "status": "ok",
  "database": "connected"
}
```

Resposta de erro retorna status `HTTP 503 Service Unavailable`:

```
{
  "status": "error",
  "database": "disconnected"
}
```

### Busca de servidores

```
GET /api/servidores?page=x&<filtros>
```

Retorna servidores ativos e aposentados, com paginação. Todos os parâmetros podem ser combinados. É

É recomendado sempre enviar a página e pelo menos um filtro de busca (`nome`, `cargo`, `uf`, `orgao` ou `similar`).

| Parâmetro | Descrição                                   | Exemplo                     |
| --------- | ------------------------------------------- | --------------------------- |
| `nome`    | Nome completo (correspondência exata)       | `nome=JOAO DA SILVA`        |
| `cargo`   | Cargo (correspondência exata)               | `cargo=PROFESSOR`           |
| `uf`      | Sigla do estado                             | `uf=SP`                     |
| `orgao`   | Órgão (correspondência exata)               | `orgao=MINISTERIO DA SAUDE` |
| `similar` | Padrão de nome, usando `%` como curinga     | `similar=%25silva%25`       |
| `limit`   | Registros por página (padrão e máximo: 100) | `limit=20`                  |
| `page`    | Número da página (padrão: 1)                | `page=2`                    |

Na URL, o `%` do parâmetro `similar` deve ser enviado como `%25`.

Valores inválidos em `limit` e `page` (como texto ou números negativos) são substituídos pelo padrão ou ajustados para o intervalo permitido.

Exemplos:

```
http://localhost:3000/api/servidores?page=5&uf=SP&limit=80
http://localhost:3000/api/servidores?page=2&similar=%25silva%25
http://localhost:3000/api/servidores?page=7&cargo=PROFESSOR&uf=RS
```

Resposta de sucesso retorna status `HTTP 200 OK`:

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

Erro ao consultar o banco retorna status `HTTP 503 Service Unavailable`:

```
{
  "status": "error",
  "message": "Erro ao consultar banco!"
}
```

Excesso de buscas simultâneas retorna status `HTTP 429 Too Many Requests`:

```
{
  "status": "error",
  "message": "Muitas buscas simultâneas. Tente novamente em instantes."
}
```

## Limite de buscas simultâneas

Para evitar sobrecarga do banco, o endpoint de busca limita quantas consultas podem ser executadas ao mesmo tempo. Quando todas as vagas estão ocupadas, novas buscas são recusadas imediatamente com `HTTP 429`.

O limite pode ser definido pela variável de ambiente `MAX_BUSCAS_SIMULTANEAS`, configurada no serviço `backend` do `docker-compose.yml`. Como ela não está definida, o padrão é o dobro da quantidade de núcleos do processador, adaptando o limite à máquina de execução.

O limite vale para cada worker do Gunicorn. O total de buscas simultâneas é o limite multiplicado pelo número de workers.

### Teste do limitador

Com o backend em execução, o comando abaixo envia 50 requisições simultâneas e mostra a quantidade de respostas por código HTTP:

```bash
( for i in $(seq 1 50); do curl -s -o /dev/null -w "%{http_code}\n" "http://127.0.0.1:3000/api/servidores?similar=%25silva%25" & done; wait ) | sort | uniq -c
```

Resultado obtido com `MAX_BUSCAS_SIMULTANEAS=1` e 2 workers (2 vagas no total):

```
      2 200
     48 429
```

As 2 buscas que ocuparam as vagas foram atendidas e as demais foram recusadas, sem falhas no servidor.

## Execução com Docker e Gunicorn

O Docker Compose executa três contêineres:

| Contêiner             | Função                           | Porta no computador |
| --------------------- | -------------------------------- | ------------------- |
| `servidores-db`       | Banco de dados PostgreSQL        | `5433`              |
| `servidores-backend`  | API Flask executada com Gunicorn | `3000`              |
| `servidores-frontend` | Frontend Flutter Web com Nginx   | `8080`              |

O backend aguarda o PostgreSQL estar saudável antes de iniciar.

O backend utiliza **Gunicorn** como servidor WSGI, permitindo executar a aplicação Flask sem depender do servidor de desenvolvimento.

Sempre que o código for alterado, é necessário reconstruir as imagens com `docker compose up -d --build`.

### Acessar a API

Após iniciar os contêineres, a API estará disponível em:

```
http://localhost:3000
```

Para consultar servidores:

```
http://localhost:3000/api/servidores?uf=RS&limit=5
```

### Configuração do Gunicorn

O arquivo `backend/Dockerfile` configura o Gunicorn com:

- Endereço: `0.0.0.0:3000`
- Workers: `2`
- Threads por worker: `4`
- Timeout por worker: `60 segundos`
- Aplicação: `server:app`

O Gunicorn é iniciado automaticamente quando o contêiner do backend é executado.

### Consultar logs

```
docker compose logs backend
docker compose logs db-server
docker compose logs frontend
```

### Encerrar os serviços

Na raiz do projeto, execute:

```
docker compose down
```

Esse comando encerra e remove os contêineres, preservando o volume de dados do PostgreSQL.

**Atenção:** não utilize `docker compose down -v` se quiser manter os dados armazenados no banco.

O `init.sql` só é executado quando o banco é criado pela primeira vez. Alterações posteriores nele não são aplicadas automaticamente a um banco existente.

## Execução local (sem Docker)

### Backend

O backend é desenvolvido em Python utilizando Flask para disponibilizar os endpoints da API. A conexão com o PostgreSQL é centralizada no módulo `db.py`.

Com o banco em execução, entre na pasta `backend/` e inicie o servidor Flask:

```
cd backend
python server.py
```

A API estará disponível em `http://127.0.0.1:3000`. Caso o backend já esteja rodando no Docker, não é necessário iniciá-lo separadamente, pois ambos usam a porta `3000`.

### Frontend

O frontend foi desenvolvido em Flutter com suporte a Web e Desktop, utilizando Material 3 e arquitetura orientada a funcionalidades (_Feature-First_).

Na pasta `frontend/`, instale as dependências:

```bash
cd frontend
flutter pub get
```

Execute a aplicação na versão Web (Chrome):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Ou na versão Desktop (Windows):

```bash
flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

Caso a porta ou o IP da API sejam alterados, basta ajustar o parâmetro `--dart-define=API_BASE_URL`. Se omitido, o padrão é `http://localhost:3000`.

Para gerar os binários de produção:

```bash
flutter build web --release --dart-define=API_BASE_URL=http://127.0.0.1:3000
flutter build windows --release --dart-define=API_BASE_URL=http://127.0.0.1:3000
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

```
pip install -r requirements.txt
```

Entre na pasta do backend:

```
cd backend
```

Execute todos os testes automatizados:

```
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

Para executar o script, mantenha o backend em funcionamento na porta `3000` e, dentro da pasta `backend`, execute:

```
python tests/integration/teste_carga_real.py
```

Por padrão, o script executa a última configuração habilitada, com 20 requisições e até 10 simultâneas.

Os testes de carga demonstram o comportamento da aplicação nos cenários avaliados, mas não determinam sua capacidade máxima.

Após os testes, uma nova requisição à API retornou HTTP 200, confirmando que o backend continuou respondendo normalmente.

## Tecnologias

- Python
- Flask
- Gunicorn
- Flutter
- PostgreSQL
- Docker
- Docker Compose
