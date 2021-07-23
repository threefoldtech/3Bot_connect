import configparser

from flask import request, json, Blueprint, Response
from nanoid import generate
from stellar_sdk import Server
from stellar_sdk.client.simple_requests_client import SimpleRequestsClient

import database as db
from services.crypt import verify_signed_data
from services.payment import check_blockchain, get_payment_by_hash, init_payment

last_payment_checked_cursor = None

api_payment = Blueprint('api_payment', __name__, url_prefix="/api/payment")

config = configparser.ConfigParser()

@api_payment.before_request
def before_request():
    check_blockchain()

@api_payment.route("/", methods=["put"])
def request_payment_request_handler():
    config.read("config.ini")
    body = request.get_json()

    encoded_data = verify_signed_data(body.get('doubleName'), body.get('data'))

    if not encoded_data: return

    data = json.loads(encoded_data.decode("utf-8"))

    requested_by = data.get("requestedBy")
    amount = float(data.get("amount"))
    notes = data.get("notes") or ""

    memo = init_payment(amount, requested_by, notes)

    response = Response(
            response=json.dumps(
                    {
                        "message": memo,
                        "address": config["DIGITALTWIN_RESERVE"]["ADDRESS"],
                        "amount": amount
                    }),
            mimetype="application/json"
    )
    return response


@api_payment.route("/<hash>", methods=["get"])
def get_payment_request_status_handler(hash):
    config.read("config.ini")

    payment = get_payment_by_hash(hash)

    response = Response(
            response=json.dumps(
                    {
                        "payment": payment,
                    }),
            mimetype="application/json"
    )
    return response

