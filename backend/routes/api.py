import psycopg, logging
from flask import Blueprint, jsonify, request as req
from db import get_connection
from psycopg.rows import dict_row
from limitador import limitar_concorrencia

api = Blueprint("api", __name__, url_prefix="/api")

@api.route("/servidores", methods=['GET'])
@limitar_concorrencia
def search():
    def safe_cast(param, tipo, default):
        try:
            return tipo(param)
        except:
            return default
        
    nome = req.args.get("nome", None)
    cargo = req.args.get("cargo", None)
    uf = req.args.get("uf", None)
    orgao = req.args.get("orgao", None)
    similar = req.args.get("similar", None)
    limite = safe_cast(req.args.get("limit"), int, 100)
    pagina = safe_cast(req.args.get("page"), int, 1)
    limite = max(1, min(limite, 100))
    pagina = max(1, pagina)
    
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

    query = "SELECT nome, cpf, cargo, uf, orgao, remuneracao FROM servidores_busca"
    if combinacoes:
        query += " WHERE " + " AND ".join(combinacoes)

    try:
        result = []
        with get_connection() as conn:
            cur = conn.cursor(row_factory=dict_row)

            cur.execute(query, parametros)
            total = len(cur.fetchall())

            parametros.append(limite)
            parametros.append((pagina - 1) * limite)
            query += " ORDER BY nome, fonte, id LIMIT %s OFFSET %s"
            cur.execute(query, parametros)
            result = cur.fetchall()
            
        return jsonify(total=total, data=result)

    except psycopg.Error as e:
        logging.error("Busca de servidores falhou: %s", e)
        return jsonify({"status": "error","message": "Erro ao consultar banco!"}), 503




