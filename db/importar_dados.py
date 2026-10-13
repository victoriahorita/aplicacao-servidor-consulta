import os
import pandas as pd
import psycopg
from dotenv import load_dotenv
from pathlib import Path

load_dotenv("../.env")

dir_dados = Path("./clean_data")
path_cargos = dir_dados/"cargos_limpos.csv"
path_aposentados = dir_dados/"aposentados_limpos.csv"

arquivos = {"cargos": path_cargos, "aposentados": path_aposentados}

colunas = {
    "cargos": ["nome", "cpf", "codigo_carreira", "descricao_cargo_emprego", "uf_upag", 
               "orgao_atuacao", "mes_referencia", "valor_remuneracao",
    ],
    "aposentados": ["nome", "cpf", "matricula_servidor", "nome_orgao", "sigla_orgao", 
                    "codigo_orgao_superior", "cargo", "classe", "padrao", "referencia", 
                    "nivel", "tipo_aposentadoria", "fundamentacao_inatividade", "nome_diploma_legal", 
                    "data_publicacao_diploma_legal", "ocorrencia_ingresso_servico_publico", 
                    "data_ingresso_servico_publico","valor_rendimento_liquido",
    ],
}

for arquivo in arquivos.values():
    if not arquivo.is_file():
        raise FileNotFoundError(f"Arquivo não encontrado: {arquivo}")

config = {
    "host": os.getenv("DB_HOST", "localhost"),
    "port": os.getenv("DB_PORT", "5433"),
    "dbname": os.getenv("DB_NAME"),
    "user": os.getenv("DB_USER"),
    "password": os.environ["DB_PASSWORD"],
}

with psycopg.connect(**config) as conexao:
    with conexao.cursor() as cursor:
        cursor.execute(
            """
            SELECT
                to_regclass('public.cargos'),
                to_regclass('public.aposentados')
            """
        )

        if not all(cursor.fetchone()):
            raise RuntimeError( "As tabelas não existem")

        cursor.execute(
            """
            SELECT
                (SELECT COUNT(*) FROM cargos),
                (SELECT COUNT(*) FROM aposentados)
            """
        )

        if any(cursor.fetchone()):
            raise RuntimeError("As tabelas já possuem registros, importação interrompida para evitar duplicações.")

        for tabela, arquivo in arquivos.items():
            df = pd.read_csv(arquivo, dtype="string")
            colunas_tabela = colunas[tabela]

            ausentes = set(colunas_tabela) - set(df.columns)
            if ausentes:
                raise ValueError(f"Colunas ausentes em {arquivo.name}: {sorted(ausentes)}")

            df = df[colunas_tabela]
            df = df.astype(object).where(pd.notna(df), None)

            colunas_sql = ", ".join(f'"{coluna}"' for coluna in colunas_tabela)

            with cursor.copy(f"COPY {tabela} ({colunas_sql}) FROM STDIN") as copia:
                for linha in df.itertuples(index=False, name=None):
                    copia.write_row(linha)

            print(f"{tabela}: {len(df)} registros importados.")

print("Importação concluída")