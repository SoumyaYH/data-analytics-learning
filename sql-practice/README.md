# SQL Practice

This folder contains my SQL learning notes and practice queries.

## Topics Covered
- SELECT statements
- WHERE conditions
- ORDER BY
- GROUP BY and aggregate functions
- JOIN operations
- Subqueries and Common Table Expressions (CTEs)
- Window functions
- CASE statements

## Practice Query 1: Find Employees with the Highest Salaries

```sql
SELECT
    employee_id,
    employee_name,
    salary
FROM Employees
ORDER BY salary DESC
LIMIT 3;
```

**Learning:** This query sorts employees by salary in descending order and returns the top three highest-paid employees.

## Goal
To improve my SQL skills by solving practical business problems.
