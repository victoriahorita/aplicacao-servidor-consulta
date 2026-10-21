import os
import threading
from functools import wraps
from flask import jsonify

MAX_BUSCAS = int(os.getenv("MAX_BUSCAS_SIMULTANEAS", (os.cpu_count() or 1) * 2))
_semaforo = threading.BoundedSemaphore(MAX_BUSCAS)

def limitar_concorrencia(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not _semaforo.acquire(blocking=False):
            return jsonify({
                "status": "error",
                "message": "Muitas buscas simultâneas. Tente novamente em instantes."
            }), 429
        try:
            return func(*args, **kwargs)
        finally:
            _semaforo.release()
    return wrapper