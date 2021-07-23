import configparser
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


# insert_user_sql, double_name, sid, email, public_key, device_id
# def insert_user(double_name, email, public_key):

# def get_user_by_double_name(double_name):


# print(get_user_by_double_name("zaibon.3bot"))
# print(insert_user("test_jimber_006.3bot", "test006@jimber.org", "fr7P6X1GwWnvRl6ZaOqd4UqVElGyLtzPHPSwCR36y6g="))
# print(get_user_by_double_name("test_jimber_006.3bot"))
