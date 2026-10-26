-- =====================================================================
-- 04_group_by_aggregates.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] COUNT rows
SELECT COUNT(*) AS total_employees FROM employees;

-- 2) [Beginner] SUM
SELECT SUM(quantity) AS total_units_sold FROM order_items;

-- 3) [Beginner] AVG per group
SELECT department_id, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department_id;

-- 4) [Beginner] MIN and MAX per group
SELECT category,
       MIN(unit_price) AS cheapest,
       MAX(unit_price) AS most_expensive
FROM products
GROUP BY category;

-- 5) [Intermediate] Group by multiple columns
SELECT ship_country, status, COUNT(*) AS order_count
FROM orders
GROUP BY ship_country, status
ORDER BY ship_country, status;

-- 6) [Intermediate] HAVING filters groups (WHERE filters rows)
SELECT department_id, COUNT(*) AS headcount
FROM employees
GROUP BY department_id
HAVING COUNT(*) >= 3;

-- 7) [Intermediate] COUNT DISTINCT
SELECT COUNT(DISTINCT customer_id) AS customers_who_ordered
FROM orders;

-- 8) [Advanced] Monthly revenue (joins + date parts + exclude cancelled)
SELECT EXTRACT(YEAR  FROM o.order_date) AS yr,
       EXTRACT(MONTH FROM o.order_date) AS mth,
       ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount)), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p     ON p.product_id = oi.product_id
WHERE o.status <> 'Cancelled'
GROUP BY 1, 2
ORDER BY 1, 2;

-- 9) [Advanced] ROLLUP: subtotals and grand total
--    (MySQL syntax: GROUP BY category, ship_country WITH ROLLUP)
SELECT p.category, o.ship_country, SUM(oi.quantity) AS units
FROM order_items oi
JOIN orders o   ON o.order_id = oi.order_id
JOIN products p ON p.product_id = oi.product_id
GROUP BY ROLLUP (p.category, o.ship_country)
ORDER BY p.category, o.ship_country;

-- 10) [Advanced] Conditional aggregation: delivery rate per customer
SELECT c.customer_name,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
       ROUND(100.0 * SUM(CASE WHEN o.status = 'Delivered' THEN 1 ELSE 0 END) / COUNT(*), 1) AS delivery_rate_pct
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_name
HAVING COUNT(*) >= 2
ORDER BY delivery_rate_pct DESC;
