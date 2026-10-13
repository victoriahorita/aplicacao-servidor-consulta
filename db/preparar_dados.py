import pandas as pd

arquivo_cargos = "../db/raw_data/CARREIRA_082026.txt"
arquivo_aposentados = "../db/raw_data/APOSENTADOS_082026.csv"

# tipos
tipos_cargos = {
    "Nome": "Texto", "CPF": "Texto", "Código da carreira": "Texto", "Descrição do cargo emprego": "Texto", 
    "UF da UPAG de vinculação": "Texto", "Denominação do órgão de atuação": "Texto", "Mês de referência": "Texto", 
    "Valor da remuneração": "Double"
}

tipos_aposentados = {
    "Nome": "Texto", "CPF": "Texto", "Matrícula do Servidor": "Texto", "Nome do órgão": "Texto", "Sigla do órgão": "Texto",
    "Código do órgão superior": "Texto", "Cargo": "Texto", "Classe": "Texto", "Padrão": "Texto", "Referência": "Texto",
    "Nível": "Texto", "Tipo de Aposentadoria": "Texto", "Fundamentação da inatividade": "Texto", "Nome Diploma Legal": "Texto", 
    "Data publicação do Diploma Legal": "Data", "Ocorrência de ingresso no serviço público": "Texto", 
    "Data de ocorrência de ingresso no serviço público": "Data", "Valor do Rendimento Líquido": "Double"
}

# adiciona nome das colunas no df aposentados
colunas_aposentados = list(tipos_aposentados.keys())

# mapeamento para o banco
mapeamento_cargos = {
    "Nome": "nome",
    "CPF": "cpf",
    "Código da carreira": "codigo_carreira",
    "Descrição do cargo emprego": "descricao_cargo_emprego",
    "UF da UPAG de vinculação": "uf_upag",
    "Denominação do órgão de atuação": "orgao_atuacao",
    "Mês de referência": "mes_referencia",
    "Valor da remuneração": "valor_remuneracao",
}

mapeamento_aposentados = {
    "Nome": "nome",
    "CPF": "cpf",
    "Matrícula do Servidor": "matricula_servidor",
    "Nome do órgão": "nome_orgao",
    "Sigla do órgão": "sigla_orgao",
    "Código do órgão superior": "codigo_orgao_superior",
    "Cargo": "cargo",
    "Classe": "classe",
    "Padrão": "padrao",
    "Referência": "referencia",
    "Nível": "nivel",
    "Tipo de Aposentadoria": "tipo_aposentadoria",
    "Fundamentação da inatividade": "fundamentacao_inatividade",
    "Nome Diploma Legal": "nome_diploma_legal",
    "Data publicação do Diploma Legal": "data_publicacao_diploma_legal",
    "Ocorrência de ingresso no serviço público": "ocorrencia_ingresso_servico_publico",
    "Data de ocorrência de ingresso no serviço público": "data_ingresso_servico_publico",
    "Valor do Rendimento Líquido": "valor_rendimento_liquido",
}


def limpar_textos(df):
    df = df.copy()
    for coluna in df.select_dtypes(include=["object", "string"]).columns:
        df[coluna] = df[coluna].str.strip()

    df = df.replace(["", "NULL", "null", "N/A", "N/D"], pd.NA)
    return df

def ler_arquivo(caminho, skiprows=0, sem_cabecalho=False, colunas=None):
    
    df = pd.read_csv(
        caminho, sep=";", encoding="cp1252", skiprows=skiprows, dtype="string", header=None if sem_cabecalho else "infer", 
        names=colunas if sem_cabecalho else None, skipinitialspace=True, low_memory=False
    )

    df.columns = df.columns.str.strip()
    df = limpar_textos(df)

    colunas_validas = []
    for coluna in df.columns:
        if coluna and not coluna.startswith("Unnamed:"):
            colunas_validas.append(coluna)

    df = df[colunas_validas]
    df = df.dropna(axis=1, how="all")
    return df

def converter_real(serie):
    serie = serie.str.strip()
    serie = serie.str.replace(".", "", regex=False)
    serie = serie.str.replace(",", ".", regex=False)

    return pd.to_numeric(serie.str.replace(".", "", regex=False), errors="coerce")


def converter_data(serie):
    serie = serie.str.strip()
    resultado = pd.to_datetime(serie,format="%d/%m/%Y",errors="coerce")

    faltantes = resultado.isna() & serie.notna()
    resultado.loc[faltantes] = pd.to_datetime(serie.loc[faltantes],format="%d%m%Y",errors="coerce")
    return resultado


def converter_tipos(df, tipos):
    df = df.copy()

    for coluna, tipo in tipos.items():

        if coluna not in df.columns:
            print(f"Coluna não encontrada no arquivo: {coluna}")
            continue

        if tipo == "Texto":
            df[coluna] = df[coluna].astype("string")

        elif tipo == "Numérico":
            df[coluna] = pd.to_numeric(df[coluna], errors="coerce").astype("Int64")

        elif tipo == "Double":
            df[coluna] = converter_real(df[coluna])

        elif tipo == "Data":
            df[coluna] = converter_data(df[coluna])

    return df


def remover_totais(df):
    if "Nome" not in df.columns:
        return df

    linhas_servidores = []

    for nome in df["Nome"]:
        if pd.isna(nome):
            linhas_servidores.append(False)

        elif not nome.startswith("TOTAL"):
            linhas_servidores.append(True)

        else:
            linhas_servidores.append(False)

    df = df[linhas_servidores]
    return df

# log dos resultados
def log_dataframe(nome, df):
    with open("./clean_data/log.txt", "a", encoding="utf-8") as f:
        f.write(f"\n{'=' * 50}\n")
        f.write(f"{nome}\n")
        f.write(f"{'=' * 50}\n")

        f.write(f"Quantidade de registros: {len(df)}\n")
        f.write(f"Quantidade de colunas: {len(df.columns)}\n")

        f.write("\nTipos das colunas:\n")
        f.write(f"\n{df.dtypes.to_string()}\n")

        f.write("\nValores ausentes:\n")
        f.write(f"\n{df.isna().sum().to_string()}\n")

# processamento 
cargos = ler_arquivo(arquivo_cargos,skiprows=1)
cargos = remover_totais(cargos)
cargos = converter_tipos(cargos, tipos_cargos)

aposentados = ler_arquivo(arquivo_aposentados, sem_cabecalho=True, colunas=colunas_aposentados)
aposentados = remover_totais(aposentados)
aposentados = converter_tipos(aposentados, tipos_aposentados)

# log
log_dataframe("CARGOS", cargos)
log_dataframe("APOSENTADOS", aposentados)

# padronização dos nomes das colunas
cargos = cargos.rename(columns=mapeamento_cargos)
aposentados = aposentados.rename(columns=mapeamento_aposentados)

# exportar os arquivos
cargos.to_csv("./clean_data/cargos_limpos.csv", index=False, encoding="utf-8")
aposentados.to_csv("./clean_data/aposentados_limpos.csv", index=False, encoding="utf-8")

print("Arquivos salvos em clean_data/")