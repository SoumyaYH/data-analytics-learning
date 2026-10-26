-- =====================================================================
-- 07_window_functions.sql  |  10 examples: Beginner -> Advanced
-- (DATE_TRUNC is PostgreSQL; use DATE_FORMAT / FORMAT in MySQL / SQL Server)
-- =====================================================================

-- 1) [Beginner] ROW_NUMBER: unique sequence per department by salary
SELECT first_name, department_id, salary,
       ROW_NUMBER() OVER (PARTITION BY department_id ORDER BY salary DESC) AS rn
FROM employees;

-- 2) [Beginner] RANK: ties share a rank, next rank is skipped (1,2,2,4)
SELECT first_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- 3) [Beginner] DENSE_RANK: ties share a rank, no gaps (1,2,2,3)
SELECT product_name, category, unit_price,
       DENSE_RANK() OVER (PARTITION BY category ORDER BY unit_price DESC) AS price_rank
FROM products;

-- 4) [Intermediate] Aggregate over the whole set: each salary as % of payroll
SELECT first_name, salary,
       SUM(salary) OVER () AS total_payroll,
       ROUND(100.0 * salary / SUM(salary) OVER (), 2) AS pct_of_payroll
FROM employees;

-- 5) [Intermediate] PARTITION BY aggregate: compare to department average
SELECT first_name, department_id, salary,
       ROUND(AVG(salary) OVER (PARTITION BY department_id), 2)          AS dept_avg,
       ROUND(salary - AVG(salary) OVER (PARTITION BY department_id), 2) AS diff_from_dept_avg
FROM employees
WHERE department_id IS NOT NULL;

-- 6) [Intermediate] Running total of order revenue
WITH order_totals AS (
    SELECT o.order_id, o.order_date,
           SUM(oi.quantity * p.unit_price * (1 - oi.discount)) AS order_total
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE o.status <> 'Cancelled'
    GROUP BY o.order_id, o.order_date
)
SELECT order_id, order_date, ROUND(order_total, 2) AS order_total,
       ROUND(SUM(order_total) OVER (ORDER BY order_date, order_id
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS running_total
FROM order_totals;

-- 7) [Intermediate] LAG: month-over-month revenue growth
WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date) AS month,
           SUM(oi.quantity * p.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE o.status <> 'Cancelled'
    GROUP BY 1
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
                   / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly;

-- 8) [Advanced] LEAD: days until the next hire in the same department
SELECT first_name, department_id, hire_date,
       LEAD(hire_date) OVER (PARTITION BY department_id ORDER BY hire_date) AS next_hire_date,
       LEAD(hire_date) OVER (PARTITION BY department_id ORDER BY hire_date) - hire_date AS days_to_next_hire
FROM employees
WHERE department_id IS NOT NULL;

-- 9) [Advanced] NTILE + moving average with a frame clause
SELECT first_name, salary,
       NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM employees;

WITH monthly AS (
    SELECT DATE_TRUNC('month', o.order_date) AS month,
           SUM(oi.quantity * p.unit_price * (1 - oi.discount)) AS revenue
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN products p     ON p.product_id = oi.product_id
    WHERE o.status <> 'Cancelled'
    GROUP BY 1
)
SELECT month, ROUND(revenue, 2) AS revenue,
       ROUND(AVG(revenue) OVER (ORDER BY month
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly;

-- 10) [Advanced] Top-N per group + FIRST_VALUE: top 2 products per category by revenue
WITH product_rev AS (
    SELECT p.category, p.product_name,
           SUM(oi.quantity * p.unit_price * (1 - oi.discount)) AS revenue
    FROM order_items oi
    JOIN orders o   ON o.order_id   = oi.order_id AND o.status <> 'Cancelled'
    JOIN products p ON p.product_id = oi.product_id
    GROUP BY p.category, p.product_name
),
ranked AS (
    SELECT category, product_name, revenue,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn,
           FIRST_VALUE(product_name) OVER (PARTITION BY category ORDER BY revenue DESC) AS category_best
    FROM product_rev
)
SELECT category, product_name, ROUND(revenue, 2) AS revenue, rn, category_best
FROM ranked
WHERE rn <= 2
ORDER BY category, rn;
