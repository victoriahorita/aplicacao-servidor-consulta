def test_consulta_servidores_com_banco_real(client):
    resposta = client.get("/api/servidores?uf=RS&limit=5")

    assert resposta.status_code == 200
    assert resposta.is_json

    dados = resposta.get_json()

    assert isinstance(dados, list)
    assert len(dados) <= 5

    for servidor in dados:
        assert servidor["uf"] == "RS"