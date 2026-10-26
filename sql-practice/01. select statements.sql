-- =====================================================================
-- 01_select_statements.sql  |  10 examples: Beginner -> Advanced
-- =====================================================================

-- 1) [Beginner] Select every column
SELECT * FROM employees;

-- 2) [Beginner] Select specific columns
SELECT first_name, last_name, job_title
FROM employees;

-- 3) [Beginner] Column aliases
SELECT first_name AS "First Name",
       last_name  AS "Last Name",
       salary     AS "Annual Salary"
FROM employees;

-- 4) [Beginner] Unique values with DISTINCT
SELECT DISTINCT category
FROM products;

-- 5) [Beginner] Limit the number of rows returned
SELECT product_name, unit_price
FROM products
LIMIT 5;

-- 6) [Intermediate] Calculated columns and string concatenation
SELECT first_name || ' ' || last_name AS full_name,
       salary,
       ROUND(salary / 12, 2)          AS monthly_salary
FROM employees;

-- 7) [Intermediate] DISTINCT across multiple columns
SELECT DISTINCT country, city
FROM customers;

-- 8) [Intermediate] Line-item revenue (select across a join)
SELECT oi.order_id,
       p.product_name,
       oi.quantity,
       p.unit_price,
       oi.discount,
       ROUND(oi.quantity * p.unit_price * (1 - oi.discount), 2) AS line_total
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id;

-- 9) [Advanced] String, length and date functions
SELECT UPPER(customer_name)                           AS customer_upper,
       LENGTH(email)                                  AS email_length,
       SUBSTRING(email, POSITION('@' IN email) + 1)   AS email_domain,
       EXTRACT(YEAR FROM signup_date)                 AS signup_year
FROM customers;

-- 10) [Advanced] Scalar subqueries, COALESCE and CAST in the SELECT list
SELECT e.first_name,
       e.salary,
       (SELECT ROUND(AVG(salary), 2) FROM employees)             AS company_avg,
       e.salary - (SELECT AVG(salary) FROM employees)            AS diff_from_avg,
       COALESCE(CAST(e.department_id AS VARCHAR), 'Unassigned')  AS department
FROM employees e;
