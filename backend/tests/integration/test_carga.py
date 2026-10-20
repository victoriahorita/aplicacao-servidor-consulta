from concurrent.futures import ThreadPoolExecutor
from server import app


def fazer_requisicao(numero):
    # cria um cliente de testes independente pra cada requisição
    # cliente permite acessar as rotas do Flask sem iniciar um servidor HTTP real
    with app.test_client() as client:

        # envia uma requisição ao endpoint de verificação
        resposta = client.get("/health/")

        return resposta.status_code


def test_requisicoes_simultaneas():
    # simula 10 requisições concorrentes utilizando threads
    # cada thread executa a função fazer_requisicao
    with ThreadPoolExecutor(max_workers=10) as executor:
        resultados = list(executor.map(fazer_requisicao, range(10)))

    # verifica se todas as 10 requisições foram executadas
    assert len(resultados) == 10

    # verifica se todas retornaram sucesso
    assert all(status == 200 for status in resultados)