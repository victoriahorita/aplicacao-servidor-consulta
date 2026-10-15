import psycopg, logging
from flask import Blueprint, jsonify, request as req
from db import get_connection

'''
A aplicação deverá disponibilizar endpoints para realizar as consultas na base de dados. Exemplo: 
GET /api/servidores?cargo=<cargo> 
GET /api/servidores?uf=<uf> 
GET /api/servidores?orgao=<orgao> 
GET /api/servidores?nome=<nome>&cargo=<cargo>&uf=<uf> 
GET /api/servidores?similar=”<%no%me%>”&limit=100    
(sendo busca por similaridade e 100 o número máximo de pessoas com nome similar) 
Buscas possíveis: 
● Busca por nome; 
● Busca por cargo/profissão; 
● Busca por estado (UF); 
● Busca por instituição/órgão; 
● Combinação de diferentes filtros de busca; 
● Envio dos dados dos registros encontrados no formato JSON.

'''


api = Blueprint("api", __name__, url_prefix="/api")

@api.route("/servidores", methods=['GET'])
def search():
    nome = req.args.get("nome", None)
    cargo = req.args.get("cargo", None)
    uf = req.args.get("uf", None)
    orgao = req.args.get("orgao", None)
    similar = req.args.get("similar", None)
    try:
        limite = int(req.args.get("limite", 100))
    except ValueError:
        limite = 100
    
    combinacoes = []
    parametros = []

    if nome:
        combinacoes.append("nome = %s")
        parametros.append(nome)
    if cargo:
        combinacoes.append("cargo = %s")
        parametros.append(cargo)
    if uf:
        combinacoes.append("uf = %s")
        parametros.append(uf.upper())
    if orgao:
        combinacoes.append("orgao = %s")
        parametros.append(orgao)
    if similar:
        combinacoes.append("nome ILIKE %s")
        parametros.append(similar)
    parametros.append(limite)
    

    query = "SELECT id, nome, cpf, cargo, uf, orgao, remuneracao FROM servidores_busca"
    if combinacoes:
        query += " WHERE " + " AND ".join(combinacoes) + " ORDER BY nome LIMIT %s"

    try:
        result = []
        with get_connection() as conn:
            cur = conn.cursor()
            
            for pessoa in cur.execute(query, parametros):
                result.append({"id": pessoa[0], "nome": pessoa[1], "cpf": pessoa[2], "cargo": pessoa[3], "uf": pessoa[4], "orgao": pessoa[5], "remuneracao": pessoa[6]})

        return jsonify(result)

    except psycopg.Error as e:
        logging.error("Health check falhou: %s", e)
        return jsonify({"status": "error","database": "disconnected"}), 503




