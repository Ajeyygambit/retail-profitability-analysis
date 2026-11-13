-- 02_analysis.sql — four questions, one block each. Every number in the memo comes from here.

-- Q1. Which sub-categories and products are profitable vs loss-making?
SELECT sub_category, category,
       round(sum(sales), 2)  AS sales,
       round(sum(profit), 2) AS profit,
       round(100 * sum(profit) / nullif(sum(sales), 0), 2) AS margin_pct,
       count(*) AS order_lines
FROM orders GROUP BY 1, 2 ORDER BY profit ASC;

WITH product_totals AS (
  SELECT product_name, sub_category, sum(sales) AS sales, sum(profit) AS profit
  FROM orders GROUP BY 1, 2
)
SELECT count(*) FILTER (WHERE profit < 0)                          AS loss_making_products,
       round(sum(profit) FILTER (WHERE profit < 0), 2)              AS loss_amount,
       round(100.0 * count(*) FILTER (WHERE profit < 0) / count(*), 1) AS pct_of_catalogue,
       round(100.0 * sum(sales) FILTER (WHERE profit < 0) / sum(sales), 1) AS pct_of_sales
FROM product_totals;

-- Q2. Monthly and seasonal pattern: does profit track sales?
SELECT date_trunc('month', order_date)::DATE AS month,
       round(sum(sales), 2)  AS sales,
       round(sum(profit), 2) AS profit,
       round(100 * sum(profit) / sum(sales), 2) AS margin_pct,
       count(DISTINCT order_id) AS orders
FROM orders GROUP BY 1 ORDER BY 1;

-- seasonality: average month size across the four years
SELECT monthname(order_date) AS month_name, month(order_date) AS month_number,
       round(avg(month_sales), 0) AS avg_month_sales
FROM (
  SELECT order_date, sum(sales) OVER (PARTITION BY date_trunc('month', order_date)) AS month_sales
  FROM orders
) GROUP BY 1, 2 ORDER BY avg_month_sales DESC;

-- Q3. Where has margin declined?
SELECT year(order_date) AS year, round(sum(sales), 2) AS sales, round(sum(profit), 2) AS profit,
       round(100 * sum(profit) / sum(sales), 2) AS margin_pct
FROM orders GROUP BY 1 ORDER BY 1;

SELECT category, year(order_date) AS year, round(100 * sum(profit) / sum(sales), 2) AS margin_pct
FROM orders GROUP BY 1, 2 ORDER BY 1, 2;

SELECT segment, year(order_date) AS year, round(100 * sum(profit) / sum(sales), 2) AS margin_pct
FROM orders GROUP BY 1, 2 ORDER BY 1, 2;

-- Q4. Does discount explain the losses, and what do returns cost?
SELECT CASE WHEN discount = 0    THEN '0%'
            WHEN discount <= 0.10 THEN '1-10%'
            WHEN discount <= 0.20 THEN '11-20%'
            WHEN discount <= 0.30 THEN '21-30%'
            WHEN discount <= 0.40 THEN '31-40%'
            ELSE '40%+' END AS discount_band,
       count(*) AS order_lines,
       round(sum(sales), 2)  AS sales,
       round(sum(profit), 2) AS profit,
       round(100 * sum(profit) / sum(sales), 2) AS margin_pct,
       round(100.0 * count(*) FILTER (WHERE profit < 0) / count(*), 2) AS pct_loss_making_lines
FROM orders GROUP BY 1, min(discount) ORDER BY min(discount);

SELECT count(DISTINCT r.order_id)              AS returned_orders,
       round(sum(o.sales), 2)                  AS sales_in_returned_orders,
       round(sum(o.profit), 2)                 AS profit_in_returned_orders,
       round(100.0 * sum(o.profit) / (SELECT sum(profit) FROM orders), 2) AS pct_of_total_profit
FROM orders o JOIN returns r USING (order_id)
WHERE r.is_returned;
