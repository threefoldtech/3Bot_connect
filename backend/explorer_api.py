import configparser
import urllib.parse
import requests
import logging
import codecs
import base64
import json

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()

formatter = logging.Formatter(
    "[%(asctime)s][%(filename)s:%(lineno)s - %(funcName)s()]: %(message)s",
    "%Y-%m-%d %H:%M:%S",
)
handler.setFormatter(formatter)

logger.addHandler(handler)

config = configparser.ConfigParser()
config.read("config.ini")

base_api_url = config["DEFAULT"]["BASE_API_URL"]


def convert_base64_to_hex(data):
    return base64.b64decode(data).hex()


def convert_hex_to_base64(data):
    return codecs.encode(codecs.decode(data, "hex"), "base64").decode().rstrip()


def create_user(double_name, email, public_key):
    public_key = convert_base64_to_hex(public_key)
    logger.debug("Creating user: [%s, %s, %s]", double_name, email, public_key)
    url = base_api_url + "users"

    logger.info("Url: " + url)

    user = {
        "name": double_name,
        "email": email,
        "pubkey": public_key,
        "host": "",
        "description": "",
        "signature": "",
    }

    logger.info("Data: %s", json.dumps(user))

    response = requests.post(url, json=user)

    if not response.status_code == 201:
        logger.error("Request failed: %s", response.json())
        return response.json()

    logger.info("Response: %s", response.json())

    return response.json()


# 0            1    2      3           4
# double_name, sid, email, public_key, device_id
def get_user_by_double_name(double_name):
    logger.info("Getting user: [%s]", double_name)
    url = base_api_url + "users?name=" + double_name

    logger.info("Url: %s", url)

    response = requests.get(url)
    if not response.status_code == 200:
        logger.error("Request failed: %s", response.json())
        return None

    response = response.json()
    if not len(response) == 1:
        logger.error(
            "Did not expect more or less then one object in the array: %s", response
        )
        return None

    logger.info("Response: %s", json.dumps(response))

    response[0]["pubkey"] = convert_hex_to_base64(response[0]["pubkey"])
    return response[0]


# print(get_user_by_double_name("zaibon.3bot"))
# print(insert_user("test_jimber_006.3bot", "test006@jimber.org", "fr7P6X1GwWnvRl6ZaOqd4UqVElGyLtzPHPSwCR36y6g="))
# print(get_user_by_double_name("test_jimber_006.3bot"))
