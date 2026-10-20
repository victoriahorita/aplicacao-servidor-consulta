
def test_protecao_sql_injection(client, mock_db):
    # define uma entrada que simula uma tentativa de SQL Injection
    entrada_maliciosa = "' OR 1=1 --"

    # envia a entrada maliciosa como filtro de nome
    resposta = client.get(
        "/api/servidores",
        query_string={"nome": entrada_maliciosa}
    )

    # verifica se a API processou a requisição
    assert resposta.status_code == 200

    # recupera a consulta SQL e os parâmetros enviados ao banco simulado
    argumentos = mock_db.execute.call_args.args
    query = argumentos[0]
    parametros = argumentos[1]

    # verifica se a consulta utiliza um marcador para o valor do nome
    assert "nome = %s" in query

    # verifica se a entrada maliciosa não foi inserida diretamente na consulta
    assert entrada_maliciosa not in query

    # verifica se a entrada foi enviada separadamente como parâmetro
    assert entrada_maliciosa in parametros
