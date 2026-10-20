
def test_consulta_servidores_com_banco_real(client):
    # consulta servidores do RS utilizando o banco de dados real
    resposta = client.get("/api/servidores?uf=RS&limit=5")

    # verifica se a API respondeu com sucesso e retornou JSON
    assert resposta.status_code == 200
    assert resposta.is_json

    resultado = resposta.get_json()

    # verifica a estrutura principal da resposta
    assert isinstance(resultado, dict)
    assert "data" in resultado
    assert "total" in resultado

    dados = resultado["data"]

    # verifica se os registros são retornados em uma lista e se a quantidade respeita o limite solicitado
    assert isinstance(dados, list)
    assert len(dados) <= 5

    # verifica se todos os servidores retornados pertencem ao RS
    for servidor in dados:
        assert servidor["uf"] == "RS"


def test_paginacao_com_banco_real(client):
    # consulta as duas primeiras páginas de servidores do RS
    resposta_pagina_1 = client.get("/api/servidores?uf=RS&limit=5&page=1")
    resposta_pagina_2 = client.get("/api/servidores?uf=RS&limit=5&page=2")

    # verifica se as duas consultas foram executadas com sucesso
    assert resposta_pagina_1.status_code == 200
    assert resposta_pagina_2.status_code == 200

    dados_pagina_1 = resposta_pagina_1.get_json()["data"]
    dados_pagina_2 = resposta_pagina_2.get_json()["data"]

    # verifica se cada página contém cinco registros
    assert len(dados_pagina_1) == 5
    assert len(dados_pagina_2) == 5

    # verifica se as páginas retornam registros diferentes
    assert dados_pagina_1 != dados_pagina_2


def test_filtro_orgao_com_banco_real(client):
    # busca um órgão que realmente existe no banco
    resposta_inicial = client.get("/api/servidores?limit=5")

    assert resposta_inicial.status_code == 200

    registros = resposta_inicial.get_json()["data"]

    assert len(registros) > 0

    # seleciona o primeiro órgão preenchido entre os registros encontrados
    orgao_existente = next(
        (servidor["orgao"] for servidor in registros if servidor["orgao"]),
        None
    )

    # verifica se foi possível encontrar um órgão válido
    assert orgao_existente is not None

    # realiza uma consulta utilizando o órgão encontrado
    resposta = client.get(
        "/api/servidores",
        query_string={
            "orgao": orgao_existente,
            "limit": 5
        }
    )

    assert resposta.status_code == 200

    dados = resposta.get_json()["data"]

    # confirma que a consulta encontrou registros
    assert len(dados) > 0

    # verifica se todos pertencem ao órgão pesquisado
    for servidor in dados:
        assert servidor["orgao"] == orgao_existente


def test_busca_similaridade_com_banco_real(client):
    # obtém um nome existente no banco
    resposta_inicial = client.get("/api/servidores?limit=1")

    assert resposta_inicial.status_code == 200

    registros = resposta_inicial.get_json()["data"]
    assert len(registros) > 0

    nome = registros[0]["nome"]
    assert nome

    # seleciona os três primeiros caracteres do nome encontrado
    trecho = nome[:3]

    # pesquisa nomes que contenham o trecho selecionado
    # os símbolos de porcentagem permitem buscar caracteres antes e depois
    resposta = client.get(
        "/api/servidores",
        query_string={
            "similar": f"%{trecho}%",
            "limit": 5
        }
    )

    assert resposta.status_code == 200

    dados = resposta.get_json()["data"]

    # verifica se a pesquisa encontrou pelo menos um registro
    assert len(dados) > 0

    # verifica se todos os nomes tem o trecho pesquisado
    # casefold permite comparar os textos sem diferenciar maiúsculas e minúsculas
    for servidor in dados:
        assert trecho.casefold() in servidor["nome"].casefold()


def test_consulta_sem_resultados(client):
    # pesquisa um nome que não deve existir no banco
    resposta = client.get(
        "/api/servidores",
        query_string={
            "nome": "NOME_INEXISTENTE_TESTE_987654321",
            "limit": 5
        }
    )

    # verifica se a consulta foi executada normalmente
    assert resposta.status_code == 200
    assert resposta.is_json

    resultado = resposta.get_json()

    # verifica se a API retorna uma lista vazia e total igual a zero
    assert resultado["data"] == []
    assert resultado["total"] == 0


def test_pagina_inexistente(client):
    # solicita uma página muito distante dos registros disponíveis
    resposta = client.get(
        "/api/servidores",
        query_string={
            "uf": "RS",
            "limit": 5,
            "page": 100000000
        }
    )

    # verifica se a consulta foi executada normalmente
    assert resposta.status_code == 200
    assert resposta.is_json

    resultado = resposta.get_json()

    # verifica se a página solicitada não contém registros
    assert resultado["data"] == []

    # verifica se o total continua representando os registros encontrados
    assert resultado["total"] > 0
