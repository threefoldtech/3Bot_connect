from database import  create_table

# status:
# 0 : payment created and is pending completion
# 1 : is payed (is completed)
# 2 : wrong amount is payed
# 3 : error
sql_create_reservation_hash_table = """
    create table payment_requests
    (
        id integer
            constraint payment_requests_pk
                primary key autoincrement,
        hash text not null,
        request_by text not null,
        status integer default 0 not null,
        amount numeric not null,
        closing_transaction_hash text,
        created_at integer default (DATETIME('now')) not null,
        notes text
    );
    
    create unique index payment_requests_hash_uindex
        on payment_requests (hash);
"""

create_table(sql_create_reservation_hash_table)
