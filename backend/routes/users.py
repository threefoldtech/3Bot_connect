from flask import Blueprint, json, Response

import database as db
from services.logger import logger
from services.socket import sio, emitOrQueue

api_users = Blueprint('api_users', __name__, url_prefix="/api/users")


@api_users.route("/<doublename>", methods=["GET"])
def get_user_handler(doublename):
    logger.debug("/doublename user %s", doublename)
    user = db.get_user_by_double_name(doublename)
    if user is not None:

        logger.debug("DB /api/users/: %s", user)
        data = {"doublename": user["double_name"], "publicKey": user["public_key"]}

        response = Response(
                response=json.dumps(data), mimetype="application/json"
        )

        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response("User not found", status=404)


@api_users.route("/<doublename>/cancel", methods=["POST"])
def cancel_login_attempt(doublename):
    logger.debug("/cancel %s", doublename)
    user = db.get_user_by_double_name(doublename)

    sio.emit("cancelLogin", {"scanned": True}, room=user["double_name"])
    return Response("Canceled by User")


@api_users.route("/<doublename>/emailverified", methods=["post"])
def set_email_verified_handler(doublename):
    logger.debug("/emailverified from user %s", doublename)
    user = db.get_user_by_double_name(doublename)

    emitOrQueue("email_verification", "", room=user["double_name"])
    return Response("Ok")


@api_users.route("/<doublename>/smsverified", methods=["post"])
def set_phone_verified_handler(doublename):
    logger.debug("/smsverified from user %s", doublename)
    user = db.get_user_by_double_name(doublename)

    emitOrQueue("sms_verification", "", room=user["double_name"])
    return Response("Ok")
