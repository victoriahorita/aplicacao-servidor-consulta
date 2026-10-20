import time
from concurrent.futures import ThreadPoolExecutor
from urllib.request import urlopen
from urllib.error import HTTPError, URLError

# endereço da API executada no Docker, utilizando Gunicorn e PostgreSQL
# a consulta busca servidores do RS, retornando no máximo 5 registros
URL = "http://localhost:3000/api/servidores?uf=RS&limit=5"


def fazer_requisicao(numero):
    # registra o instante inicial para medir o tempo da requisição
    inicio = time.perf_counter()

    try:
        # envia uma requisição HTTP real à API
        # o timeout de 20 segundos evita esperas indefinidas no cliente
        with urlopen(URL, timeout=20) as resposta:
            status = resposta.status
            resposta.read()

    except HTTPError as erro:
        # registra o código HTTP caso a API retorne um erro
        status = erro.code

    except (URLError, TimeoutError):
        # considera falha quando não obtém uma resposta HTTP
        status = 0

    # calcula o tempo total gasto pela requisição
    duracao = time.perf_counter() - inicio

    return status, duracao


def executar_carga(total, simultaneas):
    # informa a quantidade de requisições e o nível de concorrência
    print(f"\nTeste: {total} requisições, {simultaneas} simultâneas")

    # executa as requisições utilizando múltiplas threads
    # max_workers define quantas podem ser executadas ao mesmo tempo
    with ThreadPoolExecutor(max_workers=simultaneas) as executor:
        resultados = list(executor.map(fazer_requisicao, range(total)))

    # conta as respostas HTTP 200 como sucessos
    sucessos = sum(1 for status, _ in resultados if status == 200)

    # as demais respostas são contabilizadas como falhas
    falhas = total - sucessos

    # obtém os tempos de execução de todas as requisições
    tempos = [duracao for _, duracao in resultados]

    # apresenta os resultados do teste de carga
    print(f"Sucessos: {sucessos}")
    print(f"Falhas: {falhas}")
    print(f"Tempo médio: {sum(tempos) / len(tempos):.2f}s")
    print(f"Maior tempo: {max(tempos):.2f}s")


if __name__ == "__main__":
    # executar_carga(total=5, simultaneas=2)
    # executar_carga(total=10, simultaneas=5)
    executar_carga(total=20, simultaneas=10)