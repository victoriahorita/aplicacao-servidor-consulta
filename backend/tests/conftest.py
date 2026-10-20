
import pytest
from unittest.mock import MagicMock
from server import app


# cria um cliente de testes para realizar requisições simuladas a API
@pytest.fixture
def client():
    # ativa o modo de testes do Flask
    app.config["TESTING"] = True

    # disponibiliza o cliente durante a execução de cada teste
    with app.test_client() as client:
        yield client


# cria uma conexão simulada para testar a API sem acessar o PostgreSQL real
@pytest.fixture
def mock_db(monkeypatch):
    # cria objetos simulados para representar a conexão e o cursor
    conexao = MagicMock()
    cursor = MagicMock()

    # configura a conexão simulada para funcionar com o bloco with
    conexao.__enter__.return_value = conexao
    conexao.cursor.return_value = cursor

    # simula o retorno de uma consulta com dois registros de servidores
    cursor.fetchall.return_value = [
        {
            "nome": "ANA SILVA",
            "cpf": "123***",
            "cargo": "PROFESSORA",
            "uf": "RS",
            "orgao": "UNIVERSIDADE",
            "remuneracao": 5000.00
        },
        {
            "nome": "JOAO SOUZA",
            "cpf": "456***",
            "cargo": "ANALISTA",
            "uf": "RS",
            "orgao": "MINISTERIO",
            "remuneracao": 6500.00
        }
    ]

    # substitui temporariamente a conexão real pela conexão simulada
    monkeypatch.setattr(
        "routes.api.get_connection",
        lambda: conexao
    )

    # disponibiliza o cursor simulado para verificar as consultas SQL
    return cursor