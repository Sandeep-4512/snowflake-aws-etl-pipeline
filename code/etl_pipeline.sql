-- =========================================================
-- ROLE & WAREHOUSE
-- =========================================================
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE WAREHOUSE etl_wh
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 360
AUTO_RESUME = TRUE
COMMENT = 'Warehouse for E-Commerce ETL Pipeline';

USE WAREHOUSE etl_wh;

-- =========================================================
-- DATABASE & SCHEMA
-- =========================================================
CREATE OR REPLACE DATABASE etl_db
COMMENT = 'Database for E-Commerce ETL Pipeline';

USE DATABASE etl_db;

CREATE OR REPLACE SCHEMA e_commerce
COMMENT = 'Schema for E-Commerce';

USE SCHEMA e_commerce;

-- =========================================================
-- RAW (STAGING) TABLE – TRANSIENT
-- =========================================================
CREATE OR REPLACE TRANSIENT TABLE orders_raw (
    order_id    STRING,
    customer_id STRING,
    product     STRING,
    quantity    STRING,
    amount      STRING,
    order_date  STRING,
    loaded_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)
COMMENT = 'Staging table for incoming S3 data';

-- =========================================================
-- STORAGE INTEGRATION (AWS S3)
-- =========================================================
CREATE OR REPLACE STORAGE INTEGRATION aws_s3_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = S3
ENABLED = TRUE
STORAGE_AWS_ROLE_ARN = '***************'
STORAGE_ALLOWED_LOCATIONS = ('***************');

DESC STORAGE INTEGRATION aws_s3_int;

-- =========================================================
-- FILE FORMAT
-- =========================================================
CREATE OR REPLACE FILE FORMAT etl_format_csv
TYPE = CSV
SKIP_HEADER = 1
FIELD_DELIMITER = ','
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

-- =========================================================
-- EXTERNAL STAGE
-- =========================================================
CREATE OR REPLACE STAGE aws_etl_stage
URL = '***************'
STORAGE_INTEGRATION = aws_s3_int
FILE_FORMAT = etl_format_csv;

-- =========================================================
-- SNOWPIPE (AUTO INGEST)
-- =========================================================
CREATE OR REPLACE PIPE etl_pipe
AUTO_INGEST = TRUE
AS
COPY INTO orders_raw (
    order_id,
    customer_id,
    product,
    quantity,
    amount,
    order_date
)
FROM @aws_etl_stage
ON_ERROR = 'CONTINUE';

-- =========================================================
-- CLEAN TARGET TABLE
-- =========================================================
CREATE OR REPLACE TABLE orders_clean (
    order_id     INT,
    customer_id  INT,
    product      STRING,
    quantity     INT,
    amount       NUMBER(10,2),
    order_date   DATE,
    inserted_at  TIMESTAMP
)
COMMENT = 'Cleaned orders table';

-- =========================================================
-- STREAM (CDC)
-- =========================================================
CREATE OR REPLACE STREAM etl_stream
ON TABLE orders_raw
COMMENT = 'CDC stream on raw orders';

-- =========================================================
-- TASK (TRANSFORMATION)
-- =========================================================
CREATE OR REPLACE TASK etl_task
WAREHOUSE = etl_wh
SCHEDULE = 'USING CRON */5 * * * * UTC'
WHEN SYSTEM$STREAM_HAS_DATA('etl_stream')
AS
INSERT INTO orders_clean
SELECT
    order_id::INT,
    customer_id::INT,
    product,
    quantity::INT,
    amount::NUMBER(10,2),
    order_date::DATE,
    loaded_at
FROM etl_stream;

ALTER TASK etl_task RESUME;

-- =========================================================
-- VALIDATION
-- =========================================================
SELECT COUNT(*) FROM orders_raw;
SELECT COUNT(*) FROM orders_clean;
SELECT * FROM orders_clean ORDER BY inserted_at DESC;
