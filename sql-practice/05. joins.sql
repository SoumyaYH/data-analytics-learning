-- =====================================================================
-- 05_joins.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] INNER JOIN: only matching rows
SELECT e.first_name, e.job_title, d.department_name
FROM employees e
INNER JOIN departments d ON d.department_id = e.department_id;

-- 2) [Beginner] LEFT JOIN: keep all employees (Mia has no department)
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON d.department_id = e.department_id;

-- 3) [Beginner] RIGHT JOIN: keep all departments (Legal has no employees)
SELECT d.department_name, e.first_name
FROM employees e
RIGHT JOIN departments d ON d.department_id = e.department_id;

-- 4) [Intermediate] FULL OUTER JOIN: keep unmatched rows from both sides
--    (not supported in MySQL; emulate with LEFT JOIN UNION RIGHT JOIN)
SELECT e.first_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON d.department_id = e.department_id;

-- 5) [Intermediate] CROSS JOIN: every combination (reporting scaffold)
SELECT c.country, p.category
FROM (SELECT DISTINCT country  FROM customers) c
CROSS JOIN (SELECT DISTINCT category FROM products) p
ORDER BY c.country, p.category;

-- 6) [Intermediate] SELF JOIN: employee and their manager
SELECT e.first_name AS employee,
       m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON m.employee_id = e.manager_id;

-- 7) [Intermediate] Multi-table join: who bought what
SELECT c.customer_name, o.order_id, o.order_date, p.product_name, oi.quantity
FROM customers c
JOIN orders o       ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products p     ON p.product_id  = oi.product_id
ORDER BY o.order_date;

-- 8) [Advanced] Anti-join: rows with NO match
SELECT c.customer_name                      -- customers who never ordered
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;

SELECT p.product_name                       -- products never sold
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- 9) [Advanced] Join + aggregation, keeping customers with zero revenue
SELECT c.customer_name,
       COALESCE(ROUND(SUM(oi.quantity * p.unit_price * (1 - oi.discount)), 2), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o       ON o.customer_id = c.customer_id AND o.status <> 'Cancelled'
LEFT JOIN order_items oi ON oi.order_id   = o.order_id
LEFT JOIN products p     ON p.product_id  = oi.product_id
GROUP BY c.customer_name
ORDER BY total_revenue DESC;

-- 10) [Advanced] Non-equi self join: unique colleague pairs in the same department
SELECT a.first_name AS employee_a,
       b.first_name AS employee_b,
       d.department_name,
       ABS(a.salary - b.salary) AS salary_gap
FROM employees a
JOIN employees b   ON a.department_id = b.department_id
                  AND a.employee_id   < b.employee_id
JOIN departments d ON d.department_id = a.department_id
ORDER BY d.department_name, salary_gap DESC;
