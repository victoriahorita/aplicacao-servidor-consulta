def test_conexao_banco_real(client):
    # realiza uma consulta a API utilizando o PostgreSQL real
    resposta = client.get("/api/servidores?limit=1")

    # verifica se a consulta foi executada com sucesso e retornou JSON
    assert resposta.status_code == 200
    assert resposta.is_json


def test_estrutura_dados_banco_real(client):
    # consulta um registro para verificar a estrutura dos dados retornados
    resposta = client.get("/api/servidores?limit=1")

    assert resposta.status_code == 200

    resultado = resposta.get_json()

    # verifica se a resposta contém os campos principais
    assert "data" in resultado
    assert "total" in resultado

    # verifica se os campos possuem os tipos esperados
    assert isinstance(resultado["data"], list)
    assert isinstance(resultado["total"], int)

    # verifica se a consulta retornou exatamente um registro
    assert len(resultado["data"]) == 1

    servidor = resultado["data"][0]

    # verifica se o registro contém todos os campos esperados
    assert "nome" in servidor
    assert "cpf" in servidor
    assert "cargo" in servidor
    assert "uf" in servidor
    assert "orgao" in servidor
    assert "remuneracao" in servidor


def test_filtro_cargo_banco_real(client):
    # obtém um cargo existente no banco
    resposta_inicial = client.get("/api/servidores?limit=1")

    assert resposta_inicial.status_code == 200

    registros = resposta_inicial.get_json()["data"]
    assert len(registros) == 1

    cargo_existente = registros[0]["cargo"]
    assert cargo_existente

    # consulta o banco utilizando o cargo encontrado
    resposta = client.get(
        "/api/servidores",
        query_string={"cargo": cargo_existente, "limit": 5}
    )

    assert resposta.status_code == 200

    resultado = resposta.get_json()
    dados = resultado["data"]

    # garante que a consulta realmente encontrou registros
    assert len(dados) > 0

    # verifica se todos os registros correspondem ao cargo pesquisado
    for servidor in dados:
        assert servidor["cargo"] == cargo_existente