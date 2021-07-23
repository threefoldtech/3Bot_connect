import base64
import configparser
import json

import nacl.encoding
import nacl.signing

import database as db

config = configparser.ConfigParser()
config.read("config.ini")


def verify_signed_data(double_name, data):
    if 'DEBUG_PLAIN_SIGNED_DATA' in config["DEFAULT"] and int(config["DEFAULT"]["DEBUG_PLAIN_SIGNED_DATA"]) == 1:
        return json.dumps(data).encode('utf8')

    user = db.get_user_by_double_name(double_name)
    return verify_signed_data_with_public_key(user["public_key"], data)


def verify_signed_data_with_public_key(public_key, data):
    decoded_data = base64.b64decode(data)
    bytes_data = bytes(decoded_data)
    public_key = base64.b64decode(public_key)
    verify_key = nacl.signing.VerifyKey(
            public_key.hex(), encoder=nacl.encoding.HexEncoder
    )
    verified_signed_data = verify_key.verify(bytes_data)
    return verified_signed_data
