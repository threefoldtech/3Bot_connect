from database import create_table

# status:
# 0 : product key created and is pending payment
# 1 : product key is payed for
# 2 : product key is used/activated
# 3 : error

sql_create_table = """
    CREATE TABLE `digitaltwin_reservations` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `double_name` integer NOT NULL,
        `product_key_id` integer NOT NULL
    )
"""

create_table(sql_create_table)
