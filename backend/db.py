import psycopg
import os
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parent.parent / ".env"
load_dotenv(env_path)

def get_connection():
    return psycopg.connect(
        host= os.getenv("DB_HOST", "localhost"),
        port= os.getenv("DB_PORT", "5432") ,
        dbname= os.getenv("DB_NAME"),
        user= os.getenv("DB_USER"),
        password= os.getenv("DB_PASSWORD"),
        connect_timeout=5,
    )
