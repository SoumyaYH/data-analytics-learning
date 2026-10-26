-- =====================================================================
-- 06_subqueries_and_ctes.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] Scalar subquery in WHERE
SELECT first_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 2) [Beginner] Subquery with IN
SELECT customer_name
FROM customers
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status = 'Pending');

-- 3) [Intermediate] Subquery in FROM (derived table)
SELECT dept_stats.department_id, dept_stats.avg_salary
FROM (SELECT department_id, AVG(salary) AS avg_salary
      FROM employees
      GROUP BY department_id) AS dept_stats
WHERE dept_stats.avg_salary > 90000;

-- 4) [Intermediate] Correlated subquery: employees earning above their own department's average
SELECT e.first_name, e.department_id, e.salary
FROM employees e
WHERE e.salary > (SELECT AVG(e2.salary)
                  FROM employees e2
                  WHERE e2.department_id = e.department_id);

-- 5) [Intermediate] EXISTS: customers with at least one delivered order
SELECT c.customer_name
FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o
              WHERE o.customer_id = c.customer_id AND o.status = 'Delivered');

-- 6) [Intermediate] NOT EXISTS: NULL-safe anti-join
SELECT p.product_name
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id);

-- 7) [Intermediate] Basic CTE
WITH high_earners AS (
    SELECT employee_id, first_name, department_id, salary
    FROM employees
    WHERE salary >= 100000
)
SELECT h.first_name, h.salary, d.department_name
FROM high_earners h
JOIN departments d ON d.department_id = h.department_id;

-- 8) [Advanced] Multiple CTEs: customers whose spend beats the average customer
WITH customer_revenue AS (
    SELECT o.customer_id,
           SUM(oi.quantity * p.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE o.status <> 'Cancelled'
    GROUP BY o.customer_id
),
avg_revenue AS (
    SELECT AVG(revenue) AS avg_rev FROM customer_revenue
)
SELECT c.customer_name, ROUND(cr.revenue, 2) AS revenue
FROM customer_revenue cr
JOIN customers c   ON c.customer_id = cr.customer_id
CROSS JOIN avg_revenue a
WHERE cr.revenue > a.avg_rev
ORDER BY cr.revenue DESC;

-- 9) [Advanced] Chained CTEs: category revenue share of total
WITH line_revenue AS (
    SELECT p.category,
           oi.quantity * p.unit_price * (1 - oi.discount) AS revenue
    FROM order_items oi
    JOIN orders o   ON o.order_id   = oi.order_id AND o.status <> 'Cancelled'
    JOIN products p ON p.product_id = oi.product_id
),
category_revenue AS (
    SELECT category, SUM(revenue) AS revenue
    FROM line_revenue
    GROUP BY category
)
SELECT category,
       ROUND(revenue, 2) AS revenue,
       ROUND(100.0 * revenue / (SELECT SUM(revenue) FROM category_revenue), 1) AS pct_of_total
FROM category_revenue
ORDER BY revenue DESC;

-- 10) [Advanced] Recursive CTE: full org chart with reporting path
WITH RECURSIVE org AS (
    SELECT employee_id, first_name, manager_id,
           0 AS level,
           CAST(first_name AS VARCHAR(500)) AS path
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.manager_id,
           o.level + 1,
           CAST(o.path || ' > ' || e.first_name AS VARCHAR(500))
    FROM employees e
    JOIN org o ON e.manager_id = o.employee_id
)
SELECT level, path
FROM org
ORDER BY path;
