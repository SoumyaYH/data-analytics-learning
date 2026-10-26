-- =====================================================================
-- 00_setup.sql  |  Sample schema + data used by every example in this repo
-- Dialect: PostgreSQL (works with minor tweaks in MySQL / SQL Server)
-- =====================================================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id   INT PRIMARY KEY,
    department_name VARCHAR(50),
    location        VARCHAR(50)
);

CREATE TABLE employees (
    employee_id   INT PRIMARY KEY,
    first_name    VARCHAR(50),
    last_name     VARCHAR(50),
    department_id INT,
    manager_id    INT,
    hire_date     DATE,
    salary        DECIMAL(10,2),
    job_title     VARCHAR(50)
);

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email         VARCHAR(100),
    city          VARCHAR(50),
    country       VARCHAR(50),
    signup_date   DATE
);

CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(100),
    category     VARCHAR(50),
    unit_price   DECIMAL(10,2),
    stock_qty    INT
);

CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    customer_id  INT,
    order_date   DATE,
    status       VARCHAR(20),
    ship_country VARCHAR(50)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    discount      DECIMAL(3,2)
);

INSERT INTO departments VALUES
(1,'Sales','New York'),(2,'Engineering','San Francisco'),(3,'Marketing','Austin'),
(4,'HR','Chicago'),(5,'Finance','New York'),(6,'Legal','Boston');   -- Legal has no employees

INSERT INTO employees VALUES
(1,'Alice','Johnson',2,NULL,'2018-03-15',150000,'VP Engineering'),
(2,'Bob','Smith',2,1,'2019-07-01',120000,'Senior Engineer'),
(3,'Carol','White',2,1,'2021-01-10',95000,'Engineer'),
(4,'David','Brown',1,NULL,'2017-05-20',130000,'Sales Director'),
(5,'Eva','Green',1,4,'2020-09-12',70000,'Sales Rep'),
(6,'Frank','Black',1,4,'2022-02-01',65000,'Sales Rep'),
(7,'Grace','Lee',3,NULL,'2019-11-30',110000,'Marketing Manager'),
(8,'Henry','Adams',3,7,'2023-04-18',60000,'Marketing Analyst'),
(9,'Ivy','Chen',4,NULL,'2016-08-08',90000,'HR Manager'),
(10,'Jack','Wilson',2,2,'2023-06-05',85000,'Junior Engineer'),
(11,'Karen','Davis',5,NULL,'2018-12-03',125000,'Finance Manager'),
(12,'Leo','Martin',5,11,'2021-10-21',78000,'Accountant'),
(13,'Mia','Clark',NULL,4,'2024-01-15',55000,'Intern');             -- no department

INSERT INTO customers VALUES
(1,'Acme Corp','buyer@acme.com','New York','USA','2022-01-15'),
(2,'Globex','orders@globex.co.uk','London','UK','2022-03-22'),
(3,'Initech','purchasing@initech.com','Austin','USA','2022-06-10'),
(4,'Umbrella Ltd','buy@umbrella.de','Berlin','Germany','2022-09-05'),
(5,'Stark Industries','supply@stark.com','New York','USA','2023-01-20'),
(6,'Wayne Enterprises','procure@wayne.com','Chicago','USA','2023-03-14'),
(7,'Wonka Foods','orders@wonka.fr','Paris','France','2023-05-30'),
(8,'Hooli','it@hooli.com','San Francisco','USA','2023-08-08'),
(9,'Soylent Co','ops@soylent.ca','Toronto','Canada','2023-11-11'),
(10,'Pied Piper','hello@piedpiper.com','San Francisco','USA','2024-02-02'); -- no orders

INSERT INTO products VALUES
(1,'Laptop Pro','Electronics',1200.00,50),
(2,'Wireless Mouse','Electronics',25.00,200),
(3,'Mechanical Keyboard','Electronics',85.00,120),
(4,'Monitor 27 inch','Electronics',300.00,75),
(5,'Office Chair','Furniture',220.00,40),
(6,'Standing Desk','Furniture',450.00,25),
(7,'Notebook Pack','Stationery',12.50,500),
(8,'Pen Set','Stationery',8.99,800),
(9,'Desk Lamp','Furniture',35.00,0),                                   -- never ordered
(10,'USB-C Hub','Electronics',45.00,150);

INSERT INTO orders VALUES
(1,1,'2023-01-10','Delivered','USA'),(2,1,'2023-02-15','Delivered','USA'),
(3,2,'2023-02-20','Delivered','UK'),(4,3,'2023-03-05','Cancelled','USA'),
(5,4,'2023-03-18','Delivered','Germany'),(6,5,'2023-04-02','Delivered','USA'),
(7,5,'2023-05-12','Shipped','USA'),(8,6,'2023-06-21','Delivered','USA'),
(9,7,'2023-07-07','Delivered','France'),(10,8,'2023-08-15','Pending','USA'),
(11,1,'2023-09-09','Delivered','USA'),(12,2,'2023-10-10','Shipped','UK'),
(13,8,'2023-11-25','Delivered','USA'),(14,9,'2024-01-05','Delivered','Canada'),
(15,5,'2024-02-14','Pending','USA');

INSERT INTO order_items VALUES
(1,1,1,2,0),(2,1,2,2,0),(3,2,3,1,0.05),(4,2,4,2,0),(5,3,5,4,0.10),
(6,3,6,1,0),(7,4,7,10,0),(8,5,1,1,0),(9,5,10,3,0),(10,6,4,5,0.10),
(11,6,3,5,0.10),(12,7,2,10,0),(13,8,6,2,0),(14,8,5,2,0.05),(15,9,8,50,0),
(16,9,7,20,0),(17,10,1,3,0.05),(18,11,10,5,0),(19,11,2,5,0),(20,12,4,1,0),
(21,13,1,1,0),(22,13,3,2,0),(23,14,6,1,0),(24,15,8,30,0),(25,15,7,15,0.05);
