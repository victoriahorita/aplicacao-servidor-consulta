from flask import Flask
from flask_cors import CORS
from routes.health import health
from routes.api import api

app = Flask(__name__)
CORS(app)

app.register_blueprint(health)
app.register_blueprint(api)

if __name__ == '__main__': 
    app.run(port=3000, debug=True)
    