from database import  create_table

# status:
# 0 : product key created and is pending payment
# 1 : product key is payed for
# 2 : product key is used/activated
# 3 : error

sql_create_table = """
CREATE TABLE `productkeys` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `key` varchar(100) NOT NULL,
        `payment_request_id` integer NOT NULL,
        `status` integer  NOT NULL default 0,
        `activated_directly` boolean default false
    )
"""

create_table(sql_create_table)
