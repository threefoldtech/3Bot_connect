# hash
# request_by
# status
# amount
# closing_transaction_hash
# created_at
# notes
import configparser

from nanoid import generate
from stellar_sdk import Server
from stellar_sdk.client.simple_requests_client import SimpleRequestsClient

import database as db

last_payment_checked_cursor = None
config = configparser.ConfigParser()


def init_payment(amount, request_by, notes=None):
    hash = generate(size=10)
    db.insert_payment_request(hash, amount, request_by, notes)
    return hash


def get_payment_by_hash(hash):
    return db.get_payment_request_by_hash(hash)


def check_blockchain():
    global last_payment_checked_cursor
    config.read("config.ini")
    horizon_url = config["STELLAR"]["HORIZON_URL"]
    server = Server(horizon_url=horizon_url, client=SimpleRequestsClient())
    # get a list of transactions submitted by a particular account

    ## currently only one address is available for payment
    account_id = config["DIGITALTWIN_RESERVE"]["ADDRESS"]

    while True:
        payments_builder = server.payments()
        payments_builder.for_account(account_id=account_id)

        if last_payment_checked_cursor is not None:
            payments_builder.cursor(last_payment_checked_cursor)

        payments = payments_builder.call()
        payment_records = payments['_embedded']['records']

        if not payment_records: break

        for payment_record in payment_records:
            if not payment_record['transaction_successful']: continue
            if payment_record['type'] != "payment": continue

            if not payment_record.get("transaction_successful"): continue

            transaction_hash = payment_record['transaction_hash']
            transaction_builder = server.transactions()
            transaction_builder.transaction(transaction_hash)
            transaction = transaction_builder.call()
            memo = transaction.get('memo')

            # db.activate_payment(memo, transaction_hash)
            payment_request = get_payment_by_hash(memo)

            if payment_request is None: continue

            ## currently only one TFT is available for payment
            if payment_record.get("asset_type") != config["DIGITALTWIN_RESERVE"]["ASSET_TYPE"]: continue
            if payment_record.get("asset_code") != config["DIGITALTWIN_RESERVE"]["ASSET_CODE"]: continue
            if payment_record.get("asset_issuer") != config["DIGITALTWIN_RESERVE"]["ASSET_ISSUER"]: continue

            if float(payment_record.get("amount")) < float(payment_request["amount"]): continue

            if payment_request["status"] != 0: continue

            db.activate_payment_request(memo, transaction_hash)

        last_payment_checked_cursor = payment_records[-1]['id']


def check_payment():
    return None
