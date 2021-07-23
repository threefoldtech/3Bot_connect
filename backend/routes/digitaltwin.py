import configparser

from flask import request, json, Blueprint, Response
from nanoid import generate
from stellar_sdk import Server
from stellar_sdk.client.simple_requests_client import SimpleRequestsClient

import database as db
from services.crypt import verify_signed_data
from services.digitaltwin import activate_digitaltwin, insert_valid_reservations
from services.payment import check_blockchain
from services.productkeys import get_productkey_for_name, activate_productkeys, activate_personal_keys, init_productkey

last_payment_checked_cursor = None

api_digitaltwin = Blueprint('api_digitaltwin', __name__, url_prefix="/api/digitaltwin")

config = configparser.ConfigParser()


@api_digitaltwin.before_request
def before_request():
    check_blockchain()
    activate_productkeys()

    #Activates product keys with parameter activated_directly on True
    insert_valid_reservations()

@api_digitaltwin.route("/productkey", methods=["put"])
def reserve_productkey_handler():
    config.read("config.ini")
    body = request.get_json()

    encoded_data = verify_signed_data(body.get('doubleName'), body.get('data'))

    if not encoded_data: return

    data = json.loads(encoded_data.decode("utf-8"))
    reservation_by = data.get("doubleName")
    activated_directly = data.get("activated_directly")

    payment_request = init_productkey(reservation_by, activated_directly)

    response = Response(
            response=json.dumps(
                    {
                        "message": payment_request['hash'], "address": config["DIGITALTWIN_RESERVE"]["ADDRESS"],
                        "amount": float(payment_request['amount'])
                    }),
            mimetype="application/json"
    )
    return response


@api_digitaltwin.route("/productkey/<double_name>", methods=["get"])
def status_productkey_handler(double_name):
    productkeys = get_productkey_for_name(double_name)
    response = Response(
            response=json.dumps(
                    {
                        "productkeys": productkeys
                    }),
            mimetype="application/json"
    )
    return response


@api_digitaltwin.route("/productkey/activate", methods=["post"])
def activate_productkey_handler():
    config.read("config.ini")
    body = request.get_json()

    encoded_data = verify_signed_data(body.get('doubleName'), body.get('data'))

    if not encoded_data: return

    data = json.loads(encoded_data.decode("utf-8"))
    double_name = data.get("doubleName").lower()
    productkey = data.get("productKey")

    isActivated = activate_digitaltwin(double_name, productkey)

    response = Response(
            response=json.dumps(
                    {
                        "activated": isActivated
                    }),
            mimetype="application/json"
    )
    return response


@api_digitaltwin.route("/reserve/<double_name>", methods=["get"])
def check_reserve_handler(double_name):
    reservation_by = db.is_reservation_active(double_name)

    return Response(
            response=json.dumps({"active": bool(reservation_by)}),
            mimetype="application/json"
    )

@api_digitaltwin.route("/reservation_details/<double_name>", methods=["get"])
def get_reservation_details(double_name):
    reservation_by = db.get_reservation_details(double_name)

    return Response(
            response=json.dumps(reservation_by),
            mimetype="application/json"
    )