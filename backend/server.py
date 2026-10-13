from flask import Flask
from flask_cors import CORS
from routes.health import health

app = Flask(__name__)
CORS(app)

app.register_blueprint(health)

if __name__ == '__main__': 
    app.run(port=3000, debug=True)