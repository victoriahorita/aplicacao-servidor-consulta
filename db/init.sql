CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE TABLE IF NOT EXISTS cargos (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome TEXT,
    cpf TEXT,
    codigo_carreira TEXT,
    descricao_cargo_emprego TEXT,
    uf_upag TEXT,
    orgao_atuacao TEXT,
    mes_referencia TEXT,
    valor_remuneracao DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS aposentados (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome TEXT,
    cpf TEXT,
    matricula_servidor TEXT,
    nome_orgao TEXT,
    sigla_orgao TEXT,
    codigo_orgao_superior TEXT,
    cargo TEXT,
    classe TEXT,
    padrao TEXT,
    referencia TEXT,
    nivel TEXT,
    tipo_aposentadoria TEXT,
    fundamentacao_inatividade TEXT,
    nome_diploma_legal TEXT,
    data_publicacao_diploma_legal DATE,
    ocorrencia_ingresso_servico_publico TEXT,
    data_ingresso_servico_publico DATE,
    valor_rendimento_liquido DOUBLE PRECISION
);


CREATE OR REPLACE VIEW servidores_busca AS
SELECT id, nome, cpf, descricao_cargo_emprego AS cargo, uf_upag AS uf,
orgao_atuacao AS orgao, valor_remuneracao AS remuneracao, 'cargos'::TEXT AS fonte
FROM cargos 
UNION ALL
SELECT id, nome, cpf, cargo, NULL::TEXT AS uf, nome_orgao AS orgao,
valor_rendimento_liquido AS remuneracao, 'aposentados'::TEXT AS fonte
FROM aposentados;


CREATE INDEX IF NOT EXISTS idx_cargos_nome_trgm
    ON cargos USING GIN (nome gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_aposentados_nome_trgm
    ON aposentados USING GIN (nome gin_trgm_ops);

CREATE INDEX IF NOT EXISTS idx_cargos_cargo
    ON cargos (descricao_cargo_emprego);

CREATE INDEX IF NOT EXISTS idx_aposentados_cargo
    ON aposentados (cargo);

CREATE INDEX IF NOT EXISTS idx_cargos_orgao
    ON cargos (orgao_atuacao);

CREATE INDEX IF NOT EXISTS idx_aposentados_orgao
    ON aposentados (nome_orgao);

CREATE INDEX IF NOT EXISTS idx_cargos_uf
    ON cargos (uf_upag);