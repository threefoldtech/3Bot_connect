# hash
# request_by
# status
# amount
# closing_transaction_hash
# created_at
# notes
import configparser

import database as db
from services.payment import get_payment_by_hash, init_payment
from nanoid import generate

last_payment_checked_cursor = None
config = configparser.ConfigParser()


def init_productkey(request_by, activated_directly):
    config.read('config.ini')
    amount = config["DIGITALTWIN_RESERVE"]["PRICE"]
    payment_memo = init_payment(amount, request_by, 'payment for digitaltwin productkey')
    key = generate(size=10)

    payment_request = get_payment_by_hash(payment_memo)
    db.insert_productkey(key, payment_request['id'], activated_directly)

    return payment_request


def get_productkey_by_payment(hash):
    return db.get_payment_request_by_hash(hash)


def get_productkey_for_name(doublename):
    return db.get_payment_request_by_doublename(doublename)


def get_productkey_for_key(key):
    return db.get_productkey_for_key(key)


def use_productkey(key):
    return db.use_productkey(key)


def activate_productkeys():
    db.activate_productkeys()

def activate_personal_keys():
    db.activate_personal_keys()