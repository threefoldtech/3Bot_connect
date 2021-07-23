import time
from datetime import datetime

from flask import Blueprint, request, Response, json

import database as db
from services.logger import logger
from services.crypt import verify_signed_data
from services.socket import sio

api_crypt = Blueprint('api_crypt', __name__, url_prefix="/api")


@api_crypt.route("/signedAttempt", methods=["POST"])
def sign_attempt_handler():
    data = request.get_json()

    double_name = data["doubleName"].lower()
    verified_data = verify_signed_data(double_name, data["signedAttempt"])

    if not verified_data:
        return Response("Missing signature", status=400)

    body = json.loads(verified_data)

    logger.debug("/sign: %s", body)
    logger.debug("body.get('doubleName'): %s", body.get("doubleName"))

    roomToSendTo = body.get("randomRoom")
    if roomToSendTo is None:
        roomToSendTo = body.get("doubleName")
    roomToSendTo = roomToSendTo.lower()

    logger.debug("roomToSendTo %s", roomToSendTo)
    sio.emit("signedAttempt", data, room=roomToSendTo)
    return Response("Ok")


@api_crypt.route("/mobileregistration", methods=["POST"])
def mobile_registration_handler():
    logger.debug("/mobile_registration_handler ")
    body = request.get_json()
    double_name = body.get("doubleName").lower()
    email = body.get("email").lower().strip()
    public_key = body.get("public_key")
    if double_name == None or email == None or public_key == None:
        return Response("Missing data", status=400)
    else:
        if len(double_name) > 55 and double_name.endswith(".3bot"):
            return Response(
                    "doubleName exceeds length of 50 or does not contain .3bot", status=400
            )
        user = db.get_user_by_double_name(double_name)
        if user is None:
            update_sql = "INSERT into users (double_name, sid, email, public_key, device_id) VALUES(?,?,?,?,?);"
            db.insert_user(update_sql, double_name, "", email, public_key, "")
        return Response("Succes", status=200)


@api_crypt.route("/savederivedpublickey", methods=["POST"])
def save_derived_public_key():
    body = request.get_json()
    double_name = body["doubleName"].lower()
    logger.debug(body)
    try:
        auth_header = request.headers.get("Jimber-Authorization")
        logger.debug(auth_header)
        if auth_header is not None:
            data = verify_signed_data(double_name, auth_header)
            logger.debug(data)
            if data:
                data = json.loads(data.decode("utf-8"))
                logger.debug(data)
                if data["intention"] == "post-savederivedpublickey":
                    timestamp = data["timestamp"]
                    readable_signed_timestamp = datetime.fromtimestamp(
                            int(timestamp) / 1000
                    )
                    current_timestamp = time.time() * 1000
                    readable_current_timestamp = datetime.fromtimestamp(
                            int(current_timestamp / 1000)
                    )
                    difference = (int(timestamp) - int(current_timestamp)) / 1000
                    if difference < 30:
                        derived_public_key = verify_signed_data(
                                double_name, body.get("signedDerivedPublicKey")
                        ).decode(encoding="utf-8")
                        app_id = verify_signed_data(
                                double_name, body.get("signedAppId")
                        ).decode(encoding="utf-8")

                        if double_name and derived_public_key and app_id:
                            logger.debug("Signed data has been verified")
                            return Response("", status=200)
                        else:
                            logger.debug("Signed data is not verified")

                        return Response("something went wrong", status=400)
                    else:
                        logger.debug("Timestamp was expired")
                        return Response("Request took to long", status=418)
            else:
                logger.debug("Signed timestamp inside the header could not be verified")
                return Response("something went wrong", status=404)
        else:
            logger.debug("Header was not present")
            return Response("Header was not present", status=400)
    except Exception as e:
        logger.debug("Something went wrong while trying to verify the header %s", e)
        return Response("something went wrong", status=400)
