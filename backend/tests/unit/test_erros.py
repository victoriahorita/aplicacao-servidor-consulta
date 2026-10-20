
import psycopg
from unittest.mock import MagicMock, patch


def test_erro_conexao_banco(client):
    # simula uma falha ao tentar estabelecer conexão com o PostgreSQL
    with patch(
        "routes.api.get_connection",
        side_effect=psycopg.OperationalError("Falha simulada na conexão")
    ):
        resposta = client.get("/api/servidores?uf=RS")

    # verifica se a API retorna o código de serviço indisponível
    assert resposta.status_code == 503

    dados = resposta.get_json()

    # verifica se a resposta informa que ocorreu um erro
    assert dados["status"] == "error"

    # verifica se a API retorna a mensagem de erro esperada
    assert dados["message"] == "Erro ao consultar banco!"


def test_erro_execucao_consulta(client):
    # cria uma conexão e um cursor simulados
    conexao = MagicMock()
    cursor = MagicMock()

    # configura a conexão simulada para funcionar com o bloco with
    conexao.__enter__.return_value = conexao
    conexao.cursor.return_value = cursor

    # simula uma falha durante a execução da consulta SQL
    cursor.execute.side_effect = psycopg.DatabaseError(
        "Falha simulada na execução da consulta"
    )

    # substitui temporariamente a conexão real pela conexão simulada
    with patch(
        "routes.api.get_connection",
        return_value=conexao
    ):
        resposta = client.get("/api/servidores?uf=RS")

    # verifica se a API retorna o código de serviço indisponível
    assert resposta.status_code == 503

    dados = resposta.get_json()

    # verifica se a resposta informa que ocorreu um erro
    assert dados["status"] == "error"

    # verifica se a API retorna a mensagem de erro esperada
    assert dados["message"] == "Erro ao consultar banco!"