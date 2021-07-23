import configparser

from flask import Blueprint, json, Response

config = configparser.ConfigParser()

api_misc = Blueprint('misc_users', __name__, url_prefix="/api")


@api_misc.route("/minimumversion", methods=["get"])
def minimum_version_handler():
    response = Response(
            response=json.dumps({"android": 70, "ios": 70}), mimetype="application/json"
    )
    return response


@api_misc.route("/maintenance", methods=["get"])
def maintenance_handler():
    config.read("config.ini")

    response = Response(
            response=json.dumps(
                    {"maintenance": int(config["DEFAULT"]["UNDER_MAINTENANCE"])}
            ),
            mimetype="application/json",
    )
    return response
