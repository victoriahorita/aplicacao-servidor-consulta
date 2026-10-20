
def test_consulta_por_uf(client, mock_db):
    # realiza uma consulta filtrando servidores pela UF e limitando os resultados
    resposta = client.get("/api/servidores?uf=RS&limit=5")

    # verifica se a API respondeu com sucesso e retornou JSON
    assert resposta.status_code == 200
    assert resposta.is_json

    resultado = resposta.get_json()
    dados = resultado["data"]

    # verifica se a resposta contém os dois registros simulados
    assert len(dados) == 2

    # verifica se o primeiro registro possui o nome esperado
    assert dados[0]["nome"] == "ANA SILVA"


def test_consulta_por_nome(client, mock_db):
    # realiza uma consulta utilizando o filtro por nome
    resposta = client.get("/api/servidores?nome=ANA SILVA")

    assert resposta.status_code == 200

    # recupera os argumentos da última execução da consulta SQL simulada
    argumentos = mock_db.execute.call_args.args

    query = argumentos[0]
    parametros = argumentos[1]

    # verifica se a consulta SQL contém o filtro por nome
    assert "nome = %s" in query

    # verifica se o nome pesquisado foi enviado como parâmetro
    assert "ANA SILVA" in parametros


def test_consulta_por_uf_minuscula(client, mock_db):
    # realiza uma consulta informando a UF em letras minúsculas
    resposta = client.get("/api/servidores?uf=rs")

    assert resposta.status_code == 200

    # recupera os parâmetros enviados a consulta SQL simulada
    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    # verifica se a API converteu a UF para letras maiúsculas
    assert "RS" in parametros


def test_consulta_com_filtros_combinados(client, mock_db):
    # realiza uma consulta combinando os filtros de nome, cargo e UF
    resposta = client.get(
        "/api/servidores?nome=ANA SILVA&cargo=PROFESSORA&uf=RS"
    )

    assert resposta.status_code == 200

    # recupera a consulta SQL e seus parâmetros
    argumentos = mock_db.execute.call_args.args
    query = argumentos[0]
    parametros = argumentos[1]

    # verifica se a consulta SQL contém os três filtros solicitados
    assert "nome = %s" in query
    assert "cargo = %s" in query
    assert "uf = %s" in query

    # verifica se os valores pesquisados foram enviados como parâmetros
    assert "ANA SILVA" in parametros
    assert "PROFESSORA" in parametros
    assert "RS" in parametros
