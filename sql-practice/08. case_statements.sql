-- =====================================================================
-- 08_case_statements.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] Simple CASE (matches one column against exact values)
SELECT order_id, status,
       CASE status
           WHEN 'Delivered' THEN 'Complete'
           WHEN 'Shipped'   THEN 'In transit'
           WHEN 'Pending'   THEN 'Awaiting processing'
           ELSE 'Closed'
       END AS status_label
FROM orders;

-- 2) [Beginner] Searched CASE (conditions) for stock levels
SELECT product_name, stock_qty,
       CASE
           WHEN stock_qty = 0   THEN 'Out of stock'
           WHEN stock_qty < 50  THEN 'Low stock'
           WHEN stock_qty < 200 THEN 'Healthy'
           ELSE 'Overstocked'
       END AS stock_status
FROM products;

-- 3) [Beginner] Bucketing numbers into bands
SELECT first_name, salary,
       CASE
           WHEN salary >= 120000 THEN 'Band A'
           WHEN salary >= 90000  THEN 'Band B'
           WHEN salary >= 70000  THEN 'Band C'
           ELSE 'Band D'
       END AS salary_band
FROM employees;

-- 4) [Intermediate] Labelling NULLs
SELECT first_name,
       CASE WHEN manager_id IS NULL THEN 'Top-level' ELSE 'Reports to someone' END AS hierarchy_level,
       CASE WHEN department_id IS NULL THEN 'Unassigned' ELSE 'Assigned' END       AS dept_status
FROM employees;

-- 5) [Intermediate] CASE inside ORDER BY: unassigned employees last, then by salary
SELECT first_name, department_id, salary
FROM employees
ORDER BY CASE WHEN department_id IS NULL THEN 1 ELSE 0 END,
         salary DESC;

-- 6) [Intermediate] Conditional counts per country
SELECT ship_country,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) AS delivered,
       SUM(CASE WHEN status = 'Pending'   THEN 1 ELSE 0 END) AS pending,
       SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM orders
GROUP BY ship_country;

-- 7) [Advanced] Pivot rows into columns: revenue by category per year
SELECT p.category,
       ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM o.order_date) = 2023
                      THEN oi.quantity * p.unit_price * (1 - oi.discount) ELSE 0 END), 2) AS revenue_2023,
       ROUND(SUM(CASE WHEN EXTRACT(YEAR FROM o.order_date) = 2024
                      THEN oi.quantity * p.unit_price * (1 - oi.discount) ELSE 0 END), 2) AS revenue_2024
FROM order_items oi
JOIN orders o   ON o.order_id   = oi.order_id AND o.status <> 'Cancelled'
JOIN products p ON p.product_id = oi.product_id
GROUP BY p.category;

-- 8) [Advanced] CASE in UPDATE (wrapped in a transaction so nothing is saved)
BEGIN;
UPDATE employees
SET salary = CASE
                 WHEN department_id = 2 THEN salary * 1.10
                 WHEN department_id = 1 THEN salary * 1.05
                 ELSE salary * 1.03
             END;
SELECT first_name, department_id, salary FROM employees ORDER BY employee_id;
ROLLBACK;

-- 9) [Advanced] Nested CASE: shipping priority rules
SELECT o.order_id, o.ship_country, o.status,
       CASE
           WHEN o.status IN ('Delivered', 'Cancelled') THEN 'No action'
           ELSE CASE
                    WHEN o.ship_country = 'USA' THEN 'Standard ground'
                    WHEN o.ship_country IN ('UK', 'France', 'Germany') THEN 'Express EU/UK'
                    ELSE 'International air'
                END
       END AS shipping_action
FROM orders o;

-- 10) [Advanced] Customer segmentation: CASE + CTE + aggregation
WITH customer_spend AS (
    SELECT c.customer_id, c.customer_name,
           COALESCE(SUM(oi.quantity * p.unit_price * (1 - oi.discount)), 0) AS total_spend
    FROM customers c
    LEFT JOIN orders o       ON o.customer_id = c.customer_id AND o.status <> 'Cancelled'
    LEFT JOIN order_items oi ON oi.order_id   = o.order_id
    LEFT JOIN products p     ON p.product_id  = oi.product_id
    GROUP BY c.customer_id, c.customer_name
),
segmented AS (
    SELECT customer_name, total_spend,
           CASE
               WHEN total_spend >= 5000 THEN 'Platinum'
               WHEN total_spend >= 2000 THEN 'Gold'
               WHEN total_spend >= 500  THEN 'Silver'
               WHEN total_spend > 0     THEN 'Bronze'
               ELSE 'No purchases'
           END AS segment
    FROM customer_spend
)
SELECT segment, COUNT(*) AS customers, ROUND(SUM(total_spend), 2) AS segment_revenue
FROM segmented
GROUP BY segment
ORDER BY segment_revenue DESC;
