import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
engine = create_engine(
    os.environ["MYSQL_URL"],
    connect_args={"ssl": {"ca": "ca.pem"}},
)

df = pd.read_csv("data/raw/hillstrom.csv")
df.columns = df.columns.str.lower()
df.insert(0, "customer_id", range(1, len(df) + 1))  

create_table = """
CREATE TABLE customers (
    customer_id     INT PRIMARY KEY,
    recency         TINYINT NOT NULL,
    history_segment VARCHAR(30) NOT NULL,
    history         DECIMAL(10, 2) NOT NULL,
    mens            TINYINT NOT NULL,
    womens          TINYINT NOT NULL,
    zip_code        VARCHAR(20) NOT NULL,
    newbie          TINYINT NOT NULL,
    channel         VARCHAR(20) NOT NULL,
    segment         VARCHAR(20) NOT NULL,
    visit           TINYINT NOT NULL,
    conversion      TINYINT NOT NULL,
    spend           DECIMAL(10, 2) NOT NULL
)
"""

with engine.begin() as conn:
    conn.execute(text("DROP TABLE IF EXISTS customers"))
    conn.execute(text(create_table))

df.to_sql("customers", engine, if_exists="append", index=False, chunksize=5000)

with engine.connect() as conn:
    print(conn.execute(text("SELECT segment, COUNT(*) FROM customers GROUP BY segment")).all())