import pytest
from unittest.mock import MagicMock
from server import app


@pytest.fixture     # indica que uma função prepara algo que será utilizado por outros testes
def client():       # permite enviar requisições simuladas ao Flask
    app.config["TESTING"] = True

    with app.test_client() as client:
        yield client


@pytest.fixture
def mock_db(monkeypatch):  # substitui a conexão real com PostgreSQL por uma conexão simulada
    conexao = MagicMock()
    cursor = MagicMock()

    conexao.__enter__.return_value = conexao
    conexao.cursor.return_value = cursor

    # simula o retorno de uma consulta ao banco
    cursor.execute.return_value = [
        (1, "ANA SILVA", "123***", "PROFESSORA", "RS", "UNIVERSIDADE", 5000.00),
        (2, "JOAO SOUZA", "456***", "ANALISTA", "RS", "MINISTERIO", 6500.00),
    ]

    # substitui temporariamente a função get_connection utilizada no endpoint
    monkeypatch.setattr(
        "routes.api.get_connection",
        lambda: conexao
    )

    return cursor