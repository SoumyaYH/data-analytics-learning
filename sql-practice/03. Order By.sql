-- =====================================================================
-- 03_order_by.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] Ascending (default)
SELECT first_name, salary FROM employees
ORDER BY salary;

-- 2) [Beginner] Descending
SELECT first_name, salary FROM employees
ORDER BY salary DESC;

-- 3) [Beginner] Sort by multiple columns
SELECT department_id, first_name, salary
FROM employees
ORDER BY department_id ASC, salary DESC;

-- 4) [Beginner] Sort by a column alias
SELECT first_name || ' ' || last_name AS full_name, hire_date
FROM employees
ORDER BY full_name;

-- 5) [Intermediate] Sort by an expression
SELECT product_name, unit_price, stock_qty,
       unit_price * stock_qty AS inventory_value
FROM products
ORDER BY unit_price * stock_qty DESC;

-- 6) [Intermediate] Sort by column position
SELECT customer_name, country, signup_date
FROM customers
ORDER BY 2, 3 DESC;

-- 7) [Intermediate] Control NULL placement (PostgreSQL/Oracle; MySQL lacks NULLS LAST)
SELECT first_name, manager_id
FROM employees
ORDER BY manager_id ASC NULLS LAST;

-- 8) [Advanced] Custom business order with CASE
SELECT order_id, status, order_date
FROM orders
ORDER BY CASE status
             WHEN 'Pending'   THEN 1
             WHEN 'Shipped'   THEN 2
             WHEN 'Delivered' THEN 3
             ELSE 4
         END,
         order_date DESC;

-- 9) [Advanced] Top-N with pagination (page 2, 3 rows per page) + deterministic tie-breaker
SELECT product_id, product_name, unit_price
FROM products
ORDER BY unit_price DESC, product_id
LIMIT 3 OFFSET 3;

-- 10) [Advanced] Sort aggregated results with multiple tie-breakers
SELECT d.department_name,
       COUNT(e.employee_id)       AS headcount,
       ROUND(AVG(e.salary), 2)    AS avg_salary
FROM departments d
LEFT JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY headcount DESC, avg_salary DESC NULLS LAST, d.department_name;
