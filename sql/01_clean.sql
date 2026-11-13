-- 01_clean.sql — Superstore retail: bring the raw file into two clean tables.
-- The published CSV contains two extra blocks after the 9,994 order lines:
--   1) a Person/Region block (4 rows)      -> not analysis data, dropped
--   2) a Returned/Order ID block (800 rows) -> parsed into `returns`
-- Reading the file straight into a table fails on those blocks; the split below is the fix.

-- split: keep order lines only
COPY (
  SELECT * FROM read_csv('data/superstore-raw.csv', header=true, all_varchar=true)
) TO 'data/orders-raw-clean-lines.csv' (HEADER, DELIMITER ',');  -- run the python splitter first (see README)

CREATE OR REPLACE TABLE orders AS
SELECT
  CAST("Row ID" AS INTEGER)                       AS row_id,
  "Order ID"                                      AS order_id,
  CAST(strptime("Order Date", '%m/%d/%Y') AS DATE) AS order_date,
  CAST(strptime("Ship Date",  '%m/%d/%Y') AS DATE) AS ship_date,
  "Ship Mode" AS ship_mode,
  "Customer ID" AS customer_id,
  "Customer Name" AS customer_name,
  "Segment" AS segment,
  Country AS country, City AS city, State AS state,
  "Postal Code" AS postal_code, Region AS region,
  "Product ID" AS product_id, "Category" AS category,
  "Sub-Category" AS sub_category, "Product Name" AS product_name,
  CAST(replace("Sales", ',', '') AS DOUBLE)    AS sales,
  CAST("Quantity" AS INTEGER)                  AS quantity,
  CAST("Discount" AS DOUBLE)                   AS discount,
  CAST(replace("Profit", ',', '') AS DOUBLE)   AS profit
FROM read_csv('data/orders-raw-clean-lines.csv', header=true, all_varchar=true)
WHERE TRY_CAST("Row ID" AS INTEGER) IS NOT NULL;   -- belt and braces against stray rows

CREATE OR REPLACE TABLE returns AS
SELECT CAST(is_returned AS BOOLEAN) AS is_returned, CAST(order_id AS VARCHAR) AS order_id
FROM read_csv('data/returns.csv', header=true);

-- data-quality checks: expect 9994 | 5009 | 793 | 2015-01-03..2018-12-30 | 0 | 296
SELECT (SELECT count(*) FROM orders)                    AS order_lines,
       (SELECT count(DISTINCT order_id) FROM orders)    AS orders,
       (SELECT count(DISTINCT customer_id) FROM orders) AS customers,
       (SELECT min(order_date) FROM orders)             AS first_day,
       (SELECT max(order_date) FROM orders)             AS last_day,
       (SELECT count(*) FROM orders WHERE profit IS NULL OR sales IS NULL) AS null_numerics,
       (SELECT count(DISTINCT order_id) FROM returns WHERE is_returned)    AS returned_orders;
