import logging

from flask import Flask
from flask_cors import CORS

import database as db
from routes.crypt import api_crypt
from routes.digitaltwin import api_digitaltwin
from routes.payment import api_payment
from routes.misc import api_misc
from routes.users import api_users

# from services.payment import check_blockchain
from services.socket import sio

conn = db.create_connection("pythonsqlite.db")
db.create_db(conn)

app = Flask(__name__)
app.register_blueprint(api_users)
app.register_blueprint(api_misc)
app.register_blueprint(api_digitaltwin)
app.register_blueprint(api_crypt)
app.register_blueprint(api_payment)

CORS(app, support_credentials=True, resources={r"*": {"origins": ["*"]}})

logging.getLogger("werkzeug").setLevel(level=logging.ERROR)
logging.getLogger("socketio").setLevel(level=logging.ERROR)
logging.getLogger("engineio").setLevel(level=logging.ERROR)

# check_blockchain()
sio.init_app(app, cors_allowed_origins="*")

if __name__ == "__main__":

    sio.run(app, host="0.0.0.0", port=5000)
