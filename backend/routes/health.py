import psycopg
from flask import Blueprint, jsonify
from db import get_connection

health = Blueprint("health", __name__, url_prefix="/health")

@health.route('/', methods=['GET'])
def check_health():
    try:
        with get_connection() as conn:
            conn.execute("SELECT 1")

        return jsonify({"status": "ok","database": "connected"}), 200

    except psycopg.Error:
        return jsonify({"status": "error","database": "disconnected"}), 503
