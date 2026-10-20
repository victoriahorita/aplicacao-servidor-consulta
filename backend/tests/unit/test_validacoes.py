
def test_paginacao(client, mock_db):
    # realiza uma consulta solicitando cinco registros da segunda página
    resposta = client.get("/api/servidores?limit=5&page=2")

    # verifica se a API respondeu com sucesso
    assert resposta.status_code == 200

    # recupera os parâmetros enviados a consulta SQL simulada
    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    # verifica se o limite de registros é igual a cinco
    assert parametros[-2] == 5

    # verifica se o deslocamento corresponde ao início da segunda página
    assert parametros[-1] == 5


def test_limite_invalido(client, mock_db):
    # realiza uma consulta utilizando um valor não numérico para o limite
    resposta = client.get("/api/servidores?limit=abc")

    assert resposta.status_code == 200

    # recupera os parâmetros enviados
    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    # verifica se a API utiliza o limite padrão de 100 registros
    assert parametros[-2] == 100


def test_limite_minimo(client, mock_db):
    # realiza uma consulta utilizando um limite negativo
    resposta = client.get("/api/servidores?limit=-5")

    assert resposta.status_code == 200

    # recupera os parâmetros enviados
    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    # verifica se a API ajusta o limite para o mínimo permitido de um registro
    assert parametros[-2] == 1


def test_limite_maximo(client, mock_db):
    # realiza uma consulta utilizando um limite acima do máximo permitido
    resposta = client.get("/api/servidores?limit=500")

    assert resposta.status_code == 200

    # recupera os parâmetros enviados
    argumentos = mock_db.execute.call_args.args
    parametros = argumentos[1]

    # verifica se a API ajusta o limite para o máximo permitido de 100 registros
    assert parametros[-2] == 100
