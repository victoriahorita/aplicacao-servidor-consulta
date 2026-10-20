def test_consulta_por_uf(client, mock_db):
    resposta = client.get("/api/servidores?uf=RS&limite=5")

    assert resposta.status_code == 200
    assert resposta.is_json

    dados = resposta.get_json()

    assert len(dados) == 2
    assert dados[0]["nome"] == "ANA SILVA"
    assert dados[1]["nome"] == "JOAO SOUZA"


def test_consulta_por_nome(client, mock_db):
    resposta = client.get("/api/servidores?nome=ANA SILVA")

    assert resposta.status_code == 200

    # verifica se o filtro foi enviado à consulta SQL
    argumentos = mock_db.execute.call_args.args

    query = argumentos[0]
    parametros = argumentos[1]

    assert "nome = %s" in query
    assert "ANA SILVA" in parametros


def test_consulta_por_uf_minuscula(client, mock_db):
    resposta = client.get("/api/servidores?uf=rs")

    assert resposta.status_code == 200

    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    assert "RS" in parametros


def test_consulta_com_filtros_combinados(client, mock_db):
    resposta = client.get(
        "/api/servidores?nome=ANA SILVA&cargo=PROFESSORA&uf=RS"
    )

    assert resposta.status_code == 200

    argumentos = mock_db.execute.call_args.args
    query = argumentos[0]
    parametros = argumentos[1]

    assert "nome = %s" in query
    assert "cargo = %s" in query
    assert "uf = %s" in query

    assert "ANA SILVA" in parametros
    assert "PROFESSORA" in parametros
    assert "RS" in parametros