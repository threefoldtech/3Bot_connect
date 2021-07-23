# hash
# request_by
# status
# amount
# closing_transaction_hash
# created_at
# notes
import configparser

import database as db
from services.productkeys import get_productkey_for_key, use_productkey

last_payment_checked_cursor = None
config = configparser.ConfigParser()


def activate_digitaltwin(doublename, key):
    productkey = get_productkey_for_key(key)

    if not productkey.get('status') == 1: return False

    dt = has_digitaltwin(key)

    #TODO: STILL CHECK THIS
    if dt: return False
    # if not dt: return False

    db.insert_reservation(doublename, key)
    use_productkey(key)

    return True

def has_digitaltwin(doublename):
    return db.is_reservation_active(doublename)

def insert_valid_reservations():
    return db.insert_valid_reservations()