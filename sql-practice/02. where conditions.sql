-- =====================================================================
-- 02_where_conditions.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] Equality filter
SELECT * FROM employees
WHERE department_id = 2;

-- 2) [Beginner] Comparison operator
SELECT first_name, salary
FROM employees
WHERE salary > 100000;

-- 3) [Beginner] AND: both conditions must be true
SELECT first_name, department_id, salary
FROM employees
WHERE department_id = 2
  AND salary > 90000;

-- 4) [Beginner] BETWEEN (inclusive) on dates
SELECT first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '2019-01-01' AND '2020-12-31';

-- 5) [Intermediate] IN list
SELECT product_name, category
FROM products
WHERE category IN ('Furniture', 'Stationery');

-- 6) [Intermediate] Pattern matching with LIKE
SELECT customer_name FROM customers WHERE customer_name LIKE 'S%';       -- starts with S
SELECT product_name   FROM products  WHERE product_name  LIKE '%Desk%';  -- contains Desk

-- 7) [Intermediate] NULL checks (never use = NULL)
SELECT first_name, manager_id
FROM employees
WHERE manager_id IS NULL;

-- 8) [Intermediate] NOT IN / <> for exclusions
SELECT order_id, status
FROM orders
WHERE status NOT IN ('Cancelled', 'Pending');

-- 9) [Advanced] Operator precedence: parentheses matter
SELECT product_name, category, unit_price, stock_qty
FROM products
WHERE (category = 'Electronics' OR category = 'Furniture')
  AND unit_price > 200
  AND stock_qty > 0;

-- 10) [Advanced] Index-friendly date range + subquery + NOT EXISTS
SELECT o.order_id, o.order_date, o.customer_id
FROM orders o
WHERE o.order_date >= '2023-07-01'
  AND o.order_date <  '2024-01-01'
  AND o.customer_id IN (SELECT customer_id FROM customers WHERE country = 'USA')
  AND NOT EXISTS (
        SELECT 1 FROM order_items oi
        WHERE oi.order_id = o.order_id AND oi.discount > 0
  );
