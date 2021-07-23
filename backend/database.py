import logging
import os
import sqlite3
from functools import cmp_to_key
from sqlite3 import Error

from services.digitaltwin import activate_digitaltwin

sql_create_user_table = """
    CREATE TABLE IF NOT EXISTS users (
        double_name text NOT NULL,
        sid text NULL,
        email text NULL,
        public_key text NULL,
        device_id text NULL);
"""

sql_create_userapp_table = """
    CREATE TABLE IF NOT EXISTS userapps (
        double_name text NOT NULL,
        user_app_id text NOT NULL, 
        user_app_derived_pk text NOT NULL)
"""

sql_create_migrations_table = """
    CREATE TABLE IF NOT EXISTS `migrations` (
        `id` INTEGER PRIMARY KEY,
        `migration` varchar(100) NOT NULL
    );
    """

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
        "[%(asctime)s][%(filename)s:%(lineno)s - %(funcName)s()]: %(message)s",
        "%Y-%m-%d %H:%M:%S",
)
handler.setFormatter(formatter)

logger.addHandler(handler)


def create_connection(db_file):
    try:
        logger.info("Creating connection")
        conn = sqlite3.connect(db_file, check_same_thread=False)
        return conn
    except Error as e:
        logger.debug(e)

    return None


conn = create_connection("pythonsqlite.db")
conn.row_factory = sqlite3.Row


def create_table(create_table_sql):
    try:
        logger.info("Creating table")
        c = conn.cursor()
        c.executescript(create_table_sql)
    except Error as e:
        logger.debug(e)


def insert_user(insert_user_sql, double_name, sid, email, public_key, device_id):
    try:
        logger.info("Inserting user")
        c = conn.cursor()
        c.execute(
                insert_user_sql, (double_name.lower(), sid, email, public_key, device_id)
        )
        conn.commit()
    except Error as e:
        logger.debug(e)


def get_user_by_double_name(double_name):
    find_statement = "SELECT * FROM users WHERE double_name=? LIMIT 1;"
    user = {}
    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (double_name.lower(),))
        user_response = cursor.fetchone()

        if user_response == None or len(user_response) == 0:
            return None

        for index in range(len(cursor.description)):
            user[cursor.description[index][0]] = str(user_response[index])

        return user
    except Error as e:
        logger.debug(e)


def insert_reservation(double_name, product_key_id):
    insert_reservation_sql = """
    INSERT INTO `digitaltwin_reservations` (double_name, product_key_id) VALUES (
        ?,
        ?
    ); 
    """

    try:
        logger.info("Inserting reservation")
        c = conn.cursor()
        c.execute(
                insert_reservation_sql, (double_name.lower(), product_key_id)
        )
        conn.commit()
    except Error as e:
        logger.debug(e)


def insert_payment_request(hash, amount, request_by, notes, ):
    insert_sql = """
        insert into payment_requests (
            amount,
            hash,
            notes,
            request_by
            )    
        values (
            ?,
            ?,
            ?,
            ?)
        ;
    """

    try:
        logger.info("Inserting payment_request")
        c = conn.cursor()
        c.execute(
                insert_sql, (amount, hash, notes, request_by)
        )
        try:
            conn.commit()
        except Error:
            pass
    except Error as e:
        logger.debug(e)


def activate_payment_request(hash, closing_transaction_hash):
    update_statement = """
    UPDATE payment_requests SET 
        status=1,
        closing_transaction_hash=?
    WHERE hash=? and status=0;  
    """
    try:
        cursor = conn.cursor()
        cursor.execute(update_statement, (closing_transaction_hash, hash))
        try:
            conn.commit()
        except Error:
            pass
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return None

        return reservation_response[0]

    except Error as e:
        logger.debug(e)

def insert_valid_reservations():
    #TODO: SPLIT THIS UP
    insert_valid_reservations = """ select key, payment_requests.request_by from `productkeys`  
      inner join payment_requests on productkeys.payment_request_id = payment_requests.id
    where  `productkeys`.`status` = 1 and productkeys.activated_directly = 1
        and `productkeys`.`payment_request_id` in (
            select id from payment_requests where status = 1
        ) 
        and `productkeys`.key NOT IN (select product_key_id from digitaltwin_reservations)
        """

    try:
        c = conn.cursor()
        c.execute(insert_valid_reservations)
        records = c.fetchall()

        for row in records:
            product_key = row[0]
            doublename = row[1]

            activate_digitaltwin(doublename, product_key)

    except Error as e:
        logger.debug(e)

def insert_productkey(key, payment_request_id, activated_directly):
    insert_sql = """
    INSERT INTO `productkeys` (key,payment_request_id, activated_directly) VALUES (
        ?,
        ?,
        ?
    ); 
    """

    try:
        logger.info("Inserting productkey")
        c = conn.cursor()
        c.execute(
                insert_sql, (key, payment_request_id, activated_directly)
        )
        conn.commit()
    except Error as e:
        logger.debug(e)


def get_productkey_by_hash(hash):
    find_statement = "SELECT `name` from `productkeys` WHERE `hash` == ?;"

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (hash,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return None

        print("reservation_response()")
        print(reservation_response)
        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def is_productkey_active(key):
    find_statement = """
        SELECT `reservation_by` 
        FROM `productkeys` 
        WHERE 
            `name` = ? 
            and `is_activated` = 1;
        """

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (key,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return False

        print("reservation_response()")
        print(reservation_response)
        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def is_productkey_used(key):
    find_statement = """
        SELECT `reservation_by` 
        FROM `productkeys` 
        WHERE 
            `name` = ? 
            and `is_used` = 1;
        """

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (key,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return False

        print("reservation_response()")
        print(reservation_response)
        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def get_payment_request_by_hash(hash):
    find_statement = "SELECT * from `payment_requests` WHERE `hash` == ?;"

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (hash,))
        reservation_response = cursor.fetchone()

        if reservation_response is None or len(reservation_response) == 0:
            return None

        return dict(zip(reservation_response.keys(), reservation_response))
    except Error as e:
        logger.debug(e)


def get_productkey_for_key(key):
    find_statement = "SELECT * from `productkeys` WHERE `key` == ?;"

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (key,))
        reservation_response = cursor.fetchone()

        if reservation_response is None or len(reservation_response) == 0:
            return None

        return dict(zip(reservation_response.keys(), reservation_response))
    except Error as e:
        logger.debug(e)


def get_payment_request_by_doublename(doublename):
    find_statement = """
    SELECT `productkeys`.* 
    FROM `productkeys` 
    INNER JOIN `payment_requests` ON `productkeys`.`payment_request_id` = `payment_requests`.`id`
    WHERE `payment_requests`.`request_by` = ? and productkeys.status = 1
    ;
    """

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (doublename,))
        reservation_response = cursor.fetchall()

        if reservation_response is None or len(reservation_response) == 0:
            return None

        results = []
        for row in reservation_response:
            results.append(dict(zip(row.keys(), row)))

        return results
    except Error as e:
        logger.debug(e)


def get_reservation_by_hash(hash):
    find_statement = "SELECT `name` from `reservations` WHERE `hash` == ?;"

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (hash,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return None

        print("reservation_response()")
        print(reservation_response)
        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def is_reservation_active(double_name):
    find_statement = """
        SELECT product_key_id 
        FROM digitaltwin_reservations 
        WHERE 
            double_name = ? 
        """

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (double_name,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return False
        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def get_reservation_details(double_name):
    find_statement = """
        SELECT product_key_id, double_name
        FROM digitaltwin_reservations 
        WHERE 
            double_name = ? 
        """

    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (double_name,))
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return { 'details': None}

        return {
            'details':
            {
                'key': reservation_response[0],
                'double_name': reservation_response[1]
            }
        }

    except Error as e:
        logger.debug(e)


def activate_reservation_by_hash(hash, transaction_hash):
    update_statement = """
    UPDATE reservations SET 
        is_activated=1,
        closing_transaction_hash=?
    WHERE hash=?; 
    """

    try:
        cursor = conn.cursor()
        cursor.execute(update_statement, (transaction_hash, hash,))
        conn.commit()
        reservation_response = cursor.fetchone()

        if reservation_response == None or len(reservation_response) == 0:
            return None

        return reservation_response[0]
    except Error as e:
        logger.debug(e)


def activate_productkeys():
    get_productkeys = """ select key from productkeys"""

    cursor = conn.cursor()
    cursor.execute(get_productkeys)

    items = cursor.fetchall()

    if(len(items) == 0): return

    update_statement = """
    update `productkeys`
        set    `status` = 1
    where  `productkeys`.`status` = 0
        and `productkeys`.`payment_request_id` in (
            select id from payment_requests where status = 1
        )
    """

    cursor = conn.cursor()
    cursor.execute(update_statement)

    try:
        conn.commit()

    except Error:
        pass


def activate_personal_keys():
    update_statement = """
    update `productkeys`
        set    `status` = 2
    where  `productkeys`.`activated_directly` = 1
        and `productkeys`.`payment_request_id` in (
            select id from payment_requests where status = 1
        )
    """
    cursor = conn.cursor()
    cursor.execute(update_statement)

    try:
        conn.commit()

    except Error:
        pass

def use_productkey(key):
    update_statement = """
    update `productkeys`
        set `status` = 2
    where `productkeys`.`key`=?
        and `productkeys`.`status` = 1
    """

    cursor = conn.cursor()
    cursor.execute(update_statement, (key,))
    try:
        conn.commit()
    except Error:
        pass


def create_db(conn):
    if conn is None:
        logger.debug("Error! cannot create the database connection.")
        raise Exception("Error! cannot create the database connection.")

    create_table(sql_create_user_table)
    create_table(sql_create_userapp_table)
    create_table(sql_create_migrations_table)

    c = conn.cursor()

    listFiles = []
    for item in os.listdir('./migrations/'):
        listFiles.append(item)

    sortedList = (sorted(listFiles, key=cmp_to_key(compare)))

    migrations = get_proceed_migrations()
    for item in sortedList:
        if item not in migrations:
            try:
                run('./migrations/%s' % item)
                logging.info('Running %s' % item)
                sql = """INSERT INTO migrations(id, migration) VALUES ('%i', '%s')""" % (int(item.split('-')[0]), item)
                print(sql)
                c.execute(sql)
                conn.commit()

            except Error as e:
                logger.debug(e)
                exit(1)


def get_proceed_migrations():
    conn = create_connection("pythonsqlite.db")
    c = conn.cursor()
    c.execute(""" SELECT migration from migrations""")
    return [item[0] for item in c.fetchall()]


def compare(item1, item2):
    item1 = item1.split('-')[0]
    item2 = item2.split('-')[0]
    if int(item1) < int(item2):
        return -1
    elif int(item1) > int(item2):
        return 1
    else:
        return 0


def run(runfile):
    with open(runfile, "r") as rnf:
        exec(rnf.read())
