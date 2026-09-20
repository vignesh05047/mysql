-- ============================================================================
-- SQL MASTER PRACTICE NOTEBOOK
-- Basic -> Intermediate -> Advanced
-- Rearranged from the supplied SQL practice file
-- ============================================================================
-- How to use this file:
--   1. Work from Section 01 onward.
--   2. Try each question before reading/running the solution.
--   3. Keep the DATA SETUP sections when you want a fresh database.
--   4. The final APPENDIX preserves the original pasted material unchanged.
--
-- SQL dialect: MySQL-oriented syntax (USE, LIMIT, AUTO_INCREMENT, DELIMITER,
-- stored procedures, triggers, etc.).
-- ============================================================================


-- ============================================================================
-- 00. MASTER ROADMAP
-- ============================================================================
-- Study in this order. Do not jump to window functions until joins, grouping and subqueries are comfortable.

-- 01. Database / table setup
-- 02. SELECT, DISTINCT, aliases
-- 03. WHERE and filtering
-- 04. ORDER BY / LIMIT
-- 05. Aggregate functions
-- 06. GROUP BY / HAVING
-- 07. String / date / NULL functions
-- 08. CASE expressions
-- 09. JOINs
-- 10. SELF JOIN
-- 11. Subqueries
-- 12. Derived tables / CTE-style thinking
-- 13. Window functions
-- 14. DDL / constraints / ALTER
-- 15. Views / indexes
-- 16. Stored procedures
-- 17. Triggers
-- 18. Real-world mixed interview problems


-- ============================================================================
-- 01. DATABASE AND TABLE SETUP
-- ============================================================================
-- Clean setup examples based on the employee, restaurant and sales datasets in the source.

CREATE DATABASE IF NOT EXISTS s_operator;
USE s_operator;

CREATE TABLE Employee_Sales (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    designation VARCHAR(30),
    city VARCHAR(30),
    gender VARCHAR(10),
    project_name VARCHAR(30),
    shift_type VARCHAR(20),
    experience_years INT,
    salary DECIMAL(10,2)
);

CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    salesperson VARCHAR(50),
    region VARCHAR(30),
    product_category VARCHAR(30),
    product_name VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    sale_date DATE,
    revenue DECIMAL(10,2)
);

CREATE TABLE EMP (
    EMPNO INT PRIMARY KEY,
    ENAME VARCHAR(10),
    JOB VARCHAR(10),
    MGR INT,
    HIREDATE DATE,
    SAL DECIMAL(10,2),
    COMM DECIMAL(10,2),
    DEPTNO INT
);


-- ============================================================================
-- 02. BASIC SELECT
-- ============================================================================
-- Start by selecting complete rows, then specific columns and aliases.

USE s_operator;

-- 02.01 Select all rows
SELECT *
FROM employee_sales;

-- 02.02 Select specific columns
SELECT emp_id, emp_name, department, salary
FROM employee_sales;

-- 02.03 Aliases
SELECT
    emp_name AS employee_name,
    salary AS monthly_salary
FROM employee_sales;

-- 02.04 DISTINCT values
SELECT DISTINCT city
FROM employee_sales;

SELECT DISTINCT department, designation
FROM employee_sales;


-- ============================================================================
-- 03. WHERE AND FILTERING
-- ============================================================================
-- Practice one condition first, then combine conditions.

-- 03.01 Exact match
SELECT *
FROM employee_sales
WHERE city = 'Mumbai';

-- 03.02 Multiple conditions
SELECT *
FROM employee_sales
WHERE shift_type = 'Day'
  AND gender = 'Female';

-- 03.03 BETWEEN
SELECT *
FROM employee_sales
WHERE salary BETWEEN 50000 AND 75000;

-- 03.04 IN
SELECT *
FROM employee_sales
WHERE city IN ('Mumbai', 'Pune');

-- 03.05 LIKE
SELECT *
FROM employee_sales
WHERE emp_name LIKE 'A%';

-- 03.06 NULL
SELECT *
FROM EMP
WHERE COMM IS NULL;


-- ============================================================================
-- 04. ORDER BY AND LIMIT
-- ============================================================================
-- Useful for top-N / bottom-N questions.

SELECT *
FROM employee_sales
ORDER BY salary DESC;

SELECT *
FROM employee_sales
ORDER BY salary DESC
LIMIT 5;

SELECT *
FROM employee_sales
ORDER BY salary ASC
LIMIT 5;

-- Highest-paid employee
SELECT *
FROM employee_sales
ORDER BY salary DESC
LIMIT 1;


-- ============================================================================
-- 05. AGGREGATE FUNCTIONS
-- ============================================================================
-- COUNT, SUM, AVG, MIN and MAX.

SELECT COUNT(*) AS employee_count
FROM employee_sales;

SELECT MAX(salary) AS highest_salary
FROM employee_sales;

SELECT MIN(salary) AS lowest_salary
FROM employee_sales;

SELECT AVG(salary) AS average_salary
FROM employee_sales;

SELECT SUM(salary) AS total_salary
FROM employee_sales;

SELECT
    MAX(salary) - MIN(salary) AS salary_difference
FROM employee_sales;


-- ============================================================================
-- 06. GROUP BY AND HAVING
-- ============================================================================
-- This is where your source has many useful practice questions. GROUP BY creates groups; HAVING filters groups.

-- 06.01 Count employees by department
SELECT
    department,
    COUNT(*) AS employee_count
FROM employee_sales
GROUP BY department;

-- 06.02 Multiple grouping columns
SELECT
    department,
    designation,
    COUNT(*) AS employee_count
FROM employee_sales
GROUP BY department, designation;

-- 06.03 Average salary by designation
SELECT
    designation,
    AVG(salary) AS avg_salary
FROM employee_sales
GROUP BY designation;

-- 06.04 City + gender average experience
SELECT
    city,
    gender,
    AVG(experience_years) AS avg_experience
FROM employee_sales
GROUP BY city, gender;

-- 06.05 Filter groups
SELECT
    department,
    AVG(salary) AS avg_salary
FROM employee_sales
GROUP BY department
HAVING AVG(salary) > 65000;

-- 06.06 Conditional city filter before grouping
SELECT
    designation,
    SUM(salary) AS total_salary
FROM employee_sales
WHERE city IN ('Mumbai', 'Pune')
GROUP BY designation;


-- ============================================================================
-- 07. STRING, DATE AND NULL FUNCTIONS
-- ============================================================================
-- Use these after basic filtering is comfortable.

-- String examples
SELECT
    emp_name,
    LENGTH(emp_name) AS name_length,
    UPPER(emp_name) AS upper_name,
    LOWER(emp_name) AS lower_name
FROM employee_sales;

SELECT
    emp_name,
    SUBSTRING(emp_name, 1, 1) AS first_letter
FROM employee_sales;

-- Date examples using EMP
SELECT
    ENAME,
    HIREDATE,
    YEAR(HIREDATE) AS hire_year
FROM EMP;

SELECT *
FROM EMP
WHERE YEAR(HIREDATE) = 1981;

-- NULL handling
SELECT
    ENAME,
    COALESCE(COMM, 0) AS commission
FROM EMP;


-- ============================================================================
-- 08. CASE EXPRESSIONS
-- ============================================================================
-- Categorization, conditional aggregation and custom sorting.

-- Salary category
SELECT
    emp_name,
    salary,
    CASE
        WHEN salary > 80000 THEN 'High Salary'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category
FROM employee_sales;

-- Experience level
SELECT
    emp_name,
    experience_years,
    CASE
        WHEN experience_years BETWEEN 0 AND 2 THEN 'Fresher'
        WHEN experience_years BETWEEN 3 AND 6 THEN 'Intermediate'
        WHEN experience_years BETWEEN 7 AND 10 THEN 'Senior'
        ELSE 'Expert'
    END AS experience_level
FROM employee_sales;

-- Conditional aggregation
SELECT
    department,
    SUM(CASE WHEN salary > 70000 THEN 1 ELSE 0 END) AS high_salary_count
FROM employee_sales
GROUP BY department;

-- Custom ordering
SELECT *
FROM employee_sales
ORDER BY CASE department
    WHEN 'IT' THEN 1
    WHEN 'Finance' THEN 2
    WHEN 'HR' THEN 3
    WHEN 'Sales' THEN 4
    ELSE 5
END;


-- ============================================================================
-- 09. JOINS
-- ============================================================================
-- Move from one-table questions to multi-table business questions.

-- Example restaurant schema
CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE restaurants(
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(50),
    city VARCHAR(50),
    rating DECIMAL(2,1)
);

CREATE TABLE delivery_partners(
    partner_id INT PRIMARY KEY,
    partner_name VARCHAR(50),
    vehicle_type VARCHAR(20)
);

CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    partner_id INT,
    order_amount DECIMAL(10,2),
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (partner_id) REFERENCES delivery_partners(partner_id)
);

CREATE TABLE food_items(
    item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE order_details(
    order_id INT,
    item_id INT,
    quantity INT,
    PRIMARY KEY(order_id, item_id),
    FOREIGN KEY(order_id) REFERENCES orders(order_id),
    FOREIGN KEY(item_id) REFERENCES food_items(item_id)
);

-- 09.01 Customer + order
SELECT
    c.customer_name,
    o.order_id,
    o.order_amount,
    o.order_date
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id;

-- 09.02 Customer + order + restaurant
SELECT
    c.customer_name,
    o.order_date,
    r.restaurant_name
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
INNER JOIN restaurants AS r
    ON o.restaurant_id = r.restaurant_id;

-- 09.03 Orders per restaurant
SELECT
    r.restaurant_name,
    COUNT(o.order_id) AS order_count
FROM restaurants AS r
INNER JOIN orders AS o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name;

-- 09.04 Average order value by restaurant
SELECT
    r.restaurant_name,
    AVG(o.order_amount) AS avg_order_amount
FROM restaurants AS r
INNER JOIN orders AS o
    ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name;

-- 09.05 Customers with more than 3 orders
SELECT
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 3;

-- 09.06 Total quantity sold per food item
SELECT
    f.item_name,
    SUM(od.quantity) AS total_quantity
FROM food_items AS f
INNER JOIN order_details AS od
    ON f.item_id = od.item_id
GROUP BY f.item_id, f.item_name;

-- 09.07 Delivery partner performance
SELECT
    p.partner_name,
    COUNT(o.order_id) AS order_count
FROM delivery_partners AS p
INNER JOIN orders AS o
    ON p.partner_id = o.partner_id
GROUP BY p.partner_id, p.partner_name
ORDER BY order_count DESC;


-- ============================================================================
-- 10. SELF JOIN
-- ============================================================================
-- Your restaurant_employees table uses manager_id -> emp_id, which is a classic self-join pattern.

CREATE TABLE restaurant_employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    age INT,
    designation VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    phone_no VARCHAR(15),
    city VARCHAR(50),
    restaurant_id INT,
    shift_type VARCHAR(20),
    experience_years INT,
    manager_id INT
);

-- Employee -> manager
SELECT
    e.emp_name AS employee_name,
    e.emp_id AS employee_id,
    m.emp_name AS manager_name,
    m.emp_id AS manager_id
FROM restaurant_employees AS e
INNER JOIN restaurant_employees AS m
    ON e.manager_id = m.emp_id;

-- Employee hired before manager
SELECT
    e.emp_name AS employee_name,
    e.joining_date AS employee_hire_date,
    m.emp_name AS manager_name,
    m.joining_date AS manager_hire_date
FROM restaurant_employees AS e
INNER JOIN restaurant_employees AS m
    ON e.manager_id = m.emp_id
WHERE e.joining_date < m.joining_date;

-- Employee and manager comparison
SELECT
    e.emp_name AS employee_name,
    e.salary AS employee_salary,
    m.emp_name AS manager_name,
    m.salary AS manager_salary
FROM restaurant_employees AS e
INNER JOIN restaurant_employees AS m
    ON e.manager_id = m.emp_id
WHERE e.salary > m.salary;


-- ============================================================================
-- 11. SUBQUERIES
-- ============================================================================
-- Start with scalar subqueries, then move to nested and correlated patterns.

-- 11.01 Above overall average
SELECT *
FROM employee_sales
WHERE salary > (
    SELECT AVG(salary)
    FROM employee_sales
);

-- 11.02 Second-highest salary
SELECT MAX(salary) AS second_highest_salary
FROM employee_sales
WHERE salary < (
    SELECT MAX(salary)
    FROM employee_sales
);

-- 11.03 Employees earning more than every clerk
SELECT *
FROM EMP
WHERE SAL > (
    SELECT MAX(SAL)
    FROM EMP
    WHERE JOB = 'CLERK'
);

-- 11.04 Employees in departments whose average salary is above the company average
SELECT *
FROM EMP
WHERE DEPTNO IN (
    SELECT DEPTNO
    FROM EMP
    GROUP BY DEPTNO
    HAVING AVG(SAL) > (SELECT AVG(SAL) FROM EMP)
);

-- 11.05 Highest salary per department using a tuple comparison
SELECT *
FROM EMP
WHERE (DEPTNO, SAL) IN (
    SELECT DEPTNO, MAX(SAL)
    FROM EMP
    GROUP BY DEPTNO
);

-- 11.06 Employee(s) at the Nth distinct salary level
SELECT e1.*
FROM EMP AS e1
WHERE 3 = (
    SELECT COUNT(DISTINCT e2.SAL)
    FROM EMP AS e2
    WHERE e1.SAL <= e2.SAL
);


-- ============================================================================
-- 12. DERIVED TABLES AND CTE-STYLE THINKING
-- ============================================================================
-- Your source contains several derived-table patterns. CTEs make the same logic easier to read.

-- Derived table: customer totals above average customer total
SELECT
    c.customer_name,
    SUM(o.order_amount) AS customer_total
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.order_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            c1.customer_id,
            SUM(o1.order_amount) AS customer_total
        FROM customers AS c1
        INNER JOIN orders AS o1
            ON c1.customer_id = o1.customer_id
        GROUP BY c1.customer_id
    ) AS totals
);

-- Equivalent CTE pattern
WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.order_amount) AS customer_total
    FROM customers AS c
    INNER JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT *
FROM customer_totals
WHERE customer_total > (SELECT AVG(customer_total) FROM customer_totals);


-- ============================================================================
-- 13. WINDOW FUNCTIONS
-- ============================================================================
-- Progression: ROW_NUMBER -> RANK -> DENSE_RANK -> PARTITION -> running totals -> frames -> LAG/LEAD.

-- 13.01 ROW_NUMBER
SELECT
    sales_data.*,
    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS row_num
FROM sales_data;

-- 13.02 ROW_NUMBER per category
SELECT
    sales_data.*,
    ROW_NUMBER() OVER (
        PARTITION BY product_category
        ORDER BY revenue DESC
    ) AS category_row_num
FROM sales_data;

-- 13.03 RANK
SELECT
    sales_data.*,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM sales_data;

-- 13.04 DENSE_RANK
SELECT
    sales_data.*,
    DENSE_RANK() OVER (ORDER BY revenue DESC) AS revenue_dense_rank
FROM sales_data;

-- 13.05 Rank within region
SELECT
    sales_data.*,
    RANK() OVER (
        PARTITION BY region
        ORDER BY revenue DESC
    ) AS region_rank
FROM sales_data;

-- 13.06 Running total
SELECT
    sales_data.*,
    SUM(revenue) OVER (
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM sales_data;

-- 13.07 Running total per category
SELECT
    sales_data.*,
    SUM(revenue) OVER (
        PARTITION BY product_category
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS category_running_revenue
FROM sales_data;

-- 13.08 Full partition total repeated on every row
SELECT
    sales_data.*,
    SUM(revenue) OVER (
        PARTITION BY product_category
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS category_total_revenue
FROM sales_data;

-- 13.09 Moving average over current + previous 2 rows
SELECT
    sales_data.*,
    AVG(revenue) OVER (
        ORDER BY sale_date, sale_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_revenue
FROM sales_data;

-- 13.10 LEAD / LAG
SELECT
    sales_data.*,
    LAG(revenue) OVER (ORDER BY sale_date, sale_id) AS previous_revenue,
    LEAD(revenue) OVER (ORDER BY sale_date, sale_id) AS next_revenue
FROM sales_data;

-- 13.11 NTILE
SELECT
    sales_data.*,
    NTILE(4) OVER (
        ORDER BY revenue DESC
    ) AS revenue_quartile
FROM sales_data;

-- 13.12 Top 2 sales per region
WITH ranked_sales AS (
    SELECT
        sales_data.*,
        ROW_NUMBER() OVER (
            PARTITION BY region
            ORDER BY revenue DESC
        ) AS rn
    FROM sales_data
)
SELECT *
FROM ranked_sales
WHERE rn <= 2;


-- ============================================================================
-- 14. DDL, ALTER, CONSTRAINTS AND TABLE COPYING
-- ============================================================================
-- The source contains many DDL experiments. Keep them after query practice.

CREATE TABLE emp3 (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    job VARCHAR(30),
    salary DECIMAL(10,2),
    deptno INT
);

-- Copy structure only (MySQL)
CREATE TABLE copystructure LIKE emp3;

-- Copy structure + data using SELECT
CREATE TABLE structureplusdata AS
SELECT *
FROM emp3;

-- Copy structure, then insert data separately
CREATE TABLE emp4 LIKE emp3;
INSERT INTO emp4
SELECT *
FROM emp3;

-- Add a column
ALTER TABLE emp3
ADD COLUMN bonus DECIMAL(10,2);

-- Rename a column (example syntax)
ALTER TABLE emp3
RENAME COLUMN bonus TO annual_bonus;

-- Remove a column
ALTER TABLE emp3
DROP COLUMN annual_bonus;

-- Empty a table quickly
TRUNCATE TABLE emp4;


-- ============================================================================
-- 15. VIEWS AND INDEXES
-- ============================================================================
-- Views are reusable query definitions; indexes support lookup performance.

CREATE VIEW employee_summary AS
SELECT
    emp_id,
    emp_name,
    department,
    salary
FROM employee_sales;

SELECT *
FROM employee_summary;

-- Basic index
CREATE INDEX idx_employee_department
ON employee_sales(department);

-- Composite index
CREATE INDEX idx_employee_department_salary
ON employee_sales(department, salary);

-- Inspect indexes
SHOW INDEX FROM employee_sales;

-- Remove an index when no longer needed
DROP INDEX idx_employee_department ON employee_sales;


-- ============================================================================
-- 16. STORED PROCEDURES
-- ============================================================================
-- The source includes IN, OUT and INOUT parameter practice.

DELIMITER $$

CREATE PROCEDURE display_emp()
BEGIN
    SELECT *
    FROM EMP;
END$$

DELIMITER ;

CALL display_emp();

DELIMITER $$

CREATE PROCEDURE display_emp_dept(IN p_deptno INT)
BEGIN
    SELECT *
    FROM EMP
    WHERE DEPTNO = p_deptno;
END$$

DELIMITER ;

CALL display_emp_dept(20);

DELIMITER $$

CREATE PROCEDURE highest_salary(OUT p_max_salary DECIMAL(10,2))
BEGIN
    SELECT MAX(SAL)
    INTO p_max_salary
    FROM EMP;
END$$

DELIMITER ;

CALL highest_salary(@max_salary);
SELECT @max_salary;


-- ============================================================================
-- 17. TRIGGERS
-- ============================================================================
-- Use triggers only after you understand INSERT/UPDATE/DELETE and OLD/NEW.

CREATE TABLE emp2 (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    deptno INT,
    salary DECIMAL(10,2)
);

-- BEFORE INSERT validation / normalization
DELIMITER $$

CREATE TRIGGER before_emp2_insert
BEFORE INSERT ON emp2
FOR EACH ROW
BEGIN
    IF NEW.salary < 1000 THEN
        SET NEW.salary = 1000;
    END IF;
END$$

DELIMITER ;

-- BEFORE UPDATE validation
DELIMITER $$

CREATE TRIGGER before_emp2_update
BEFORE UPDATE ON emp2
FOR EACH ROW
BEGIN
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New salary cannot be lower than old salary';
    END IF;
END$$

DELIMITER ;


-- ============================================================================
-- 18. REAL-WORLD INTERVIEW PROBLEMS
-- ============================================================================
-- Do these without looking at the solution. These combine multiple concepts from the source.

-- Q18.01 Second-highest salary
-- Q18.02 Third-highest distinct salary
-- Q18.03 Highest-paid employee in every department
-- Q18.04 Employees earning above their department average
-- Q18.05 Departments whose average salary is above company average
-- Q18.06 Customers whose total spending is above average customer spending
-- Q18.07 Restaurants whose revenue is above average restaurant revenue
-- Q18.08 Food items sold above average quantity
-- Q18.09 Top 2 orders per restaurant
-- Q18.10 Top 3 employees per department
-- Q18.11 Employee + manager comparison using SELF JOIN
-- Q18.12 Running revenue by region
-- Q18.13 First and last sale in each product category
-- Q18.14 Rank employees within each department
-- Q18.15 Find departments with at least N employees

-- Q18.01 Solution: second-highest salary
SELECT MAX(salary) AS second_highest_salary
FROM employee_sales
WHERE salary < (SELECT MAX(salary) FROM employee_sales);

-- Q18.03 Solution: highest salary per department
SELECT *
FROM employee_sales
WHERE (department, salary) IN (
    SELECT department, MAX(salary)
    FROM employee_sales
    GROUP BY department
);

-- Q18.04 Solution: above department average
SELECT e.*
FROM employee_sales AS e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employee_sales AS e2
    WHERE e2.department = e.department
);

-- Q18.09 Solution: top 2 orders per restaurant
WITH ranked_orders AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY restaurant_id
            ORDER BY order_amount DESC, order_id
        ) AS rn
    FROM orders AS o
)
SELECT *
FROM ranked_orders
WHERE rn <= 2;


-- ============================================================================
-- 19. QUALITY CHECKLIST
-- ============================================================================
-- A few issues in the original were syntax errors, inconsistent table names, duplicates, or unfinished statements. The learning version above uses cleaned examples.

-- Before running a query, ask:
--   1. What table(s) do I need?
--   2. What rows should be filtered in WHERE?
--   3. Am I grouping? If yes, what belongs in GROUP BY?
--   4. Am I filtering groups? Use HAVING.
--   5. Do I need a JOIN or a subquery?
--   6. If I need a rank/running total, use a window function.
--   7. Can the query return duplicate rows because of a JOIN?
--   8. Are NULL values handled correctly?
--   9. Is the result deterministic? Add a tie-breaker to ORDER BY where needed.
--  10. Can I explain the query line by line before moving on?


-- ============================================================================
-- APPENDIX. ORIGINAL SOURCE PRESERVED
-- ============================================================================
-- The complete original pasted file follows so none of your practice material is lost. Use the organized sections above as the main study path.

use s_operator;
select * from employee_sales;

select avg(salary) from employee_sales

where experience_years>3
group by department;


select city,count(salary) from employee_sales
where shift_type='Day'
group by city;

select department,designation,count(emp_id) from employee_sales
group by department,designation;

select project_name,max(salary),min(salary) from employee_sales
group by project_name;

select city,gender,avg(experience_years) from  employee_sales
group by city,gender;


select department,city,shift_type,count(emp_id)
from employee_sales
group by department,city,shift_type;


select designation, sum(salary) from employee_sales

where city in ('Mumbai','Pune')
group by designation;


select * from employee_sales;

select project_name,city,avg(salary)
from employee_sales
where experience_years between 3 and 8
group by project_name,city;


select department,gender,count(gender)
from employee_sales


group by departmen


ct city,department,designation,max(salary)
from employee_sales
group by city,department,designation;

select department,max(salary)-min(salary) as diifer
from employees	
group by department;

select department,project_name,avg(salary)
from employee_sales
group by department,project_name;

select city,project_name,count(emp_id)
from employee_sales
group by city,project_name;

select designation,department,sum(salary)
from employee_sales
group by designation,department;

select city,department,shift_type,avg(experience_years)
from employee_sales
group by city,department,shift_type;

use s_operator;
select *  from employee_sales;

select * from employee_sales
where city='Mumbai';

select max(salary)
from employee_sales;

select *
 from employee_sales
 where salary between 50000 and 750000;
 
 select department,count(*)
 from employee_sales
 group by department;
 
 select max(salary)
 from employee_sales
 where salary<
 
( select max(salary)
 from employee_sales);
 
select *
from employee_sales
where shift_type='Day' and gender='Female';

select designation,avg(salary)
from employee_sales
group by designation;

select *
from  employee_sales
where emp_name like 'A%';

select department,avg(salary)
from employee_sales
group by department
having avg(salary)>65000;

select *
from employee_sales
where salary>(select avg(salary)
from employee_sales);


select dis
 use s_operator;
 create database cbn1;
use cbn;
CREATE TABLE Employee_Sales (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    designation VARCHAR(30),
    city VARCHAR(30),
    gender VARCHAR(10),
    project_name VARCHAR(30),
    shift_type VARCHAR(20),
    experience_years INT,
    salary DECIMAL(10,2)
);

use s_operator;

CREATE TABLE EMP (
EMPNO INT PRIMARY KEY,
ENAME VARCHAR(10),
JOB VARCHAR(10),
MGR INT,
HIREDATE DATE,
SAL FLOAT,
COMM FLOAT,
DEPTNO INT
);

INSERT INTO EMP (EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO) VALUES
(7369, 'SMITH', 'CLERK', 7902, '1980-12-17', 800.00, NULL, 20),
(7499, 'ALLEN', 'SALESMAN', 7698, '1981-02-20', 1600.00, 300.00, 30),
(7521, 'WARD', 'SALESMAN', 7698, '1981-02-22', 1250.00, 500.00, 30),
(7566, 'JONES', 'MANAGER', 7839, '1981-04-02', 2975.00, NULL, 20),
(7654, 'MARTIN', 'SALESMAN', 7698, '1981-09-28', 1250.00, 1400.00, 30),
(7698, 'BLAKE', 'MANAGER', 7839, '1981-05-01', 2850.00, NULL, 30),
(7782, 'CLARK', 'MANAGER', 7839, '1981-06-09', 2450.00, NULL, 10),
(7788, 'SCOTT', 'ANALYST', 7566, '1982-12-09', 3000.00, NULL, 20),
(7839, 'KING', 'PRESIDENT', NULL, '1981-11-17', 5000.00, NULL, 10),
(7844, 'TURNER', 'SALESMAN', 7698, '1981-09-08', 1500.00, 0.00, 30),
(7876, 'ADAMS', 'CLERK', 7788, '1983-01-12', 1100.00, NULL, 20),
(7900, 'JAMES', 'CLERK', 7698, '1981-12-03', 950.00, NULL, 30),
(7902, 'FORD', 'ANALYST', 7566, '1981-12-03', 3000.00, NULL, 20),
(7934, 'MILLER', 'CLERK', 7782, '1982-01-23', 1300.00, NULL, 10);

select * from emp
where sal>(select avg(sal) from emp
where deptno=(select deptno from emp
where ename='ALLEN'));

select * from emp
where sal >(select max(sal) from emp where job='CLERK');

select * from emp where deptno in (select deptno from emp
group by deptno
having avg(sal)>(select avg(sal) from emp));

select * from emp
where sal =(select max(sal) from emp
where sal <(select max(sal) from emp));

select * from emp where deptno in (select deptno from emp
group by deptno having max(sal) > 5000);

select * from emp where sal > (select avg(sal) from emp
where mgr =(select empno from emp where ename='KING'));

select * from emp
where sal >(select max(sal) from emp where deptno=30);

select * from emp where sal<(select min(sal)
from emp where job='MANAGER');

select * from emp where deptno in (select deptno from emp
group by deptno having count(empno)>(select count(empno)
from emp where deptno=10));

select * from emp where sal>(select avg(sal) from emp
group by deptno order by count(*) desc limit 1);

select * from emp where (deptno,sal) in
(select deptno,max(sal) from emp group by deptno);

select * from emp where deptno in (select deptno from emp
group by deptno having min(sal)>= 1000);

select * from emp where sal>(select avg(sal) from emp
where deptno in(select deptno from emp group by deptno
having avg(sal)>(select avg(sal) from emp)));

select * from emp where deptno=(select deptno from emp
where sal =(select max(sal) from emp where sal 
(select max(sal)from emp where sal 
(select max(sal)from emp))));

select * from emp where sal>(select avg(sal) from emp
where deptno in(select deptno from emp
group by deptno having count(*)>= 4));

select * from emp where sal> (select min(sal) from emp
where deptno=20)and sal<(select max(sal)
from emp where deptno=30);


select * from emp
where sal>(select min(sal) from emp
where deptno=20)
and sal<(select max(sal) from emp
where deptno=30);	

select * from emp
where sal=(select max(sal) from emp
where year(hiredate)=(select year(hiredate) from emp
where ename='SCOTT'));

select * from emp;
where deptno in (select deptno from emp
where sal> 4000);

use s_operator;
select *
from emp
where sal=

(select avg(sal)
from emp
group by deptno
order by avg(sal) 
limit 1);



select * ,deptno from emp
group by deptno
having max(sal);

select avg(sal)
from emp;

select avg(sal)
from emp group by deptno
having sal>2073.214285714286;

select deptno
from emp
where ename='ALLEN';


select deptno, avg(sal)
from emp
group by deptno >30;


use s_operator;

select * from emp;


select sal
from emp
where sal>(select max(sal)
from emp
group by deptno
having avg(sal)<
 (select max(sal)
from emp group by deptno
having avg(sal)));


use s_operator;

select e1 .salary from emp e1
where 3=(select count(distinct e2 .salary) from emp e2
where e1.salary<=e2.salary);

select * from emp;
where sal>(select max(sal)
from emp
where job='Clerk');


select avg(sal)
from emp;

select *,avg(sal)
from emp
group by deptno
having avg(sal)>(select avg(sal)
from emp);


select *
from emp
where sal<(select avg(sal)
from(select min(sal)
from emp
where deptno is not null
group by deptno
order by min(sal)
limit 2) as derived);

use s_operator;
select * from emp;


select * from emp
 where sal<(select avg(sal) 
 from emp where deptno in(select deptno 
 from emp
 group by deptno
 order by avg(sal)
 limit 2));
 
 use s_operator;
 
 CREATE TABLE customers(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(50)
);
CREATE TABLE restaurants(
    restaurant_id INT PRIMARY KEY,
    restaurant_name VARCHAR(50),
    city VARCHAR(50),
    rating DECIMAL(2,1)
);
CREATE TABLE delivery_partners(
    partner_id INT PRIMARY KEY,
    partner_name VARCHAR(50),
    vehicle_type VARCHAR(20)
);
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT,
    restaurant_id INT,
    partner_id INT,
    order_amount DECIMAL(10,2),
    order_date DATE,
    
    FOREIGN KEY(customer_id)
    REFERENCES customers(customer_id),

    FOREIGN KEY(restaurant_id)
    REFERENCES restaurants(restaurant_id),

    FOREIGN KEY(partner_id)
    REFERENCES delivery_partners(partner_id)
);

CREATE TABLE food_items(
    item_id INT PRIMARY KEY,
    item_name VARCHAR(50),
    price DECIMAL(10,2)
);

CREATE TABLE order_details(
    order_id INT,
    item_id INT,
    quantity INT,

    PRIMARY KEY(order_id,item_id),

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id),

    FOREIGN KEY(item_id)
    REFERENCES food_items(item_id)
);

INSERT INTO customers VALUES
(1,'Rahul','Bangalore'),
(2,'Priya','Hyderabad'),
(3,'Amit','Delhi'),
(4,'Sneha','Mumbai'),
(5,'Karan','Pune'),
(6,'Riya','Chennai'),
(7,'Arjun','Bangalore'),
(8,'Neha','Hyderabad'),
(9,'Vikram','Delhi'),
(10,'Pooja','Mumbai'),
(11,'Rohan','Pune'),
(12,'Anjali','Chennai'),
(13,'Siddharth','Bangalore'),
(14,'Meera','Hyderabad'),
(15,'Abhishek','Delhi'),
(16,'Kavya','Mumbai'),
(17,'Harsh','Pune'),
(18,'Nisha','Chennai'),
(19,'Akash','Bangalore'),
(20,'Divya','Hyderabad'),
(21,'Varun','Delhi'),
(22,'Shreya','Mumbai'),
(23,'Manish','Pune'),
(24,'Aisha','Chennai'),
(25,'Yash','Bangalore'),
(26,'Tanvi','Hyderabad'),
(27,'Rajat','Delhi'),
(28,'Ishita','Mumbai'),
(29,'Deepak','Pune'),
(30,'Simran','Chennai'),
(31,'Nitin','Bangalore'),
(32,'Payal','Hyderabad'),
(33,'Gaurav','Delhi'),
(34,'Muskan','Mumbai'),
(35,'Saurabh','Pune'),
(36,'Komal','Chennai'),
(37,'Pratik','Bangalore'),
(38,'Ritika','Hyderabad'),
(39,'Mohit','Delhi'),
(40,'Sakshi','Mumbai'),
(41,'Aditya','Pune'),
(42,'Khushi','Chennai'),
(43,'Shivam','Bangalore'),
(44,'Palak','Hyderabad'),
(45,'Ayush','Delhi'),
(46,'Jiya','Mumbai'),
(47,'Naveen','Pune'),
(48,'Preeti','Chennai'),
(49,'Rakesh','Bangalore'),
(50,'Madhuri','Hyderabad');


INSERT INTO restaurants VALUES
(101,'Burger Hub','Bangalore',4.5),
(102,'Pizza World','Hyderabad',4.2),
(103,'Biryani House','Delhi',4.8),
(104,'Tandoori Treat','Mumbai',4.1),
(105,'South Spice','Chennai',4.6),
(106,'Food Junction','Pune',4.0),
(107,'Spicy Bowl','Bangalore',4.3),
(108,'Urban Kitchen','Hyderabad',4.4),
(109,'Royal Feast','Delhi',4.7),
(110,'Cafe Express','Mumbai',4.0),
(111,'Dosa Corner','Chennai',4.5),
(112,'Punjabi Dhaba','Pune',4.3),
(113,'Wrap Station','Bangalore',4.2),
(114,'Chinese Wok','Hyderabad',4.1),
(115,'Grill House','Delhi',4.6),
(116,'Street Bites','Mumbai',3.9),
(117,'Healthy Eats','Chennai',4.4),
(118,'Food Factory','Pune',4.2),
(119,'BBQ Nation','Bangalore',4.8),
(120,'Tasty Treats','Hyderabad',4.3);


INSERT INTO delivery_partners VALUES
(201,'Ramesh','Bike'),
(202,'Suresh','Scooter'),
(203,'Ankit','Bike'),
(204,'Vikas','Cycle'),
(205,'Rohit','Bike'),
(206,'Manoj','Bike'),
(207,'Tarun','Scooter'),
(208,'Ajay','Bike'),
(209,'Deepak','Cycle'),
(210,'Nitin','Bike'),
(211,'Aman','Scooter'),
(212,'Kishore','Bike'),
(213,'Vivek','Bike'),
(214,'Shyam','Cycle'),
(215,'Arun','Bike');


INSERT INTO food_items VALUES
(1,'Burger',150),
(2,'Pizza',250),
(3,'Chicken Biryani',300),
(4,'Veg Biryani',250),
(5,'Dosa',120),
(6,'Paneer Tikka',280),
(7,'Noodles',220),
(8,'Fried Rice',200),
(9,'Momos',180),
(10,'Pasta',260),
(11,'Sandwich',140),
(12,'Fries',110),
(13,'Ice Cream',90),
(14,'Coffee',100),
(15,'Tea',50),
(16,'Chicken Roll',170),
(17,'Veg Roll',150),
(18,'Manchurian',210),
(19,'Pizza Combo',350),
(20,'Burger Combo',300),
(21,'Brownie',120),
(22,'Milkshake',180),
(23,'Idli',80),
(24,'Paratha',130),
(25,'Salad',160);




INSERT INTO orders VALUES
(1001,1,101,201,450,'2025-01-01'),
(1002,2,102,202,700,'2025-01-02'),
(1003,3,103,203,850,'2025-01-03'),
(1004,4,104,204,550,'2025-01-04'),
(1005,5,105,205,400,'2025-01-05'),
(1006,6,106,206,900,'2025-01-06'),
(1007,7,107,207,650,'2025-01-07'),
(1008,8,108,208,700,'2025-01-08'),
(1009,9,109,209,1200,'2025-01-09'),
(1010,10,110,210,500,'2025-01-10'),
(1011,11,111,211,350,'2025-01-11'),
(1012,12,112,212,450,'2025-01-12'),
(1013,13,113,213,800,'2025-01-13'),
(1014,14,114,214,600,'2025-01-14'),
(1015,15,115,215,950,'2025-01-15'),
(1016,16,116,201,300,'2025-01-16'),
(1017,17,117,202,750,'2025-01-17'),
(1018,18,118,203,400,'2025-01-18'),
(1019,19,119,204,1100,'2025-01-19'),
(1020,20,120,205,650,'2025-01-20'),
(1021,21,101,206,550,'2025-01-21'),
(1022,22,102,207,700,'2025-01-22'),
(1023,23,103,208,800,'2025-01-23'),
(1024,24,104,209,500,'2025-01-24'),
(1025,25,105,210,350,'2025-01-25'),
(1026,26,106,211,650,'2025-01-26'),
(1027,27,107,212,700,'2025-01-27'),
(1028,28,108,213,600,'2025-01-28'),
(1029,29,109,214,1250,'2025-01-29'),
(1030,30,110,215,450,'2025-01-30'),
(1031,31,111,201,550,'2025-02-01'),
(1032,32,112,202,400,'2025-02-02'),
(1033,33,113,203,750,'2025-02-03'),
(1034,34,114,204,600,'2025-02-04'),
(1035,35,115,205,1000,'2025-02-05'),
(1036,36,116,206,350,'2025-02-06'),
(1037,37,117,207,500,'2025-02-07'),
(1038,38,118,208,650,'2025-02-08'),
(1039,39,119,209,1300,'2025-02-09'),
(1040,40,120,210,700,'2025-02-10'),
(1041,41,101,211,450,'2025-02-11'),
(1042,42,102,212,650,'2025-02-12'),
(1043,43,103,213,850,'2025-02-13'),
(1044,44,104,214,500,'2025-02-14'),
(1045,45,105,215,300,'2025-02-15'),
(1046,46,106,201,900,'2025-02-16'),
(1047,47,107,202,650,'2025-02-17'),
(1048,48,108,203,550,'2025-02-18'),
(1049,49,109,204,1150,'2025-02-19'),
(1050,50,120,205,700,'2025-02-20');


INSERT INTO order_details VALUES

(1001,1,2),
(1001,12,1),

(1002,2,2),
(1002,13,2),

(1003,3,2),
(1003,14,1),

(1004,6,1),
(1004,21,2),

(1005,5,3),
(1005,15,2),

(1006,2,2),
(1006,22,2),

(1007,7,2),
(1007,13,1),

(1008,10,2),
(1008,14,2),

(1009,3,3),
(1009,21,2),

(1010,1,2),
(1010,22,1),

(1011,5,2),
(1011,15,1),

(1012,24,2),
(1012,14,2),

(1013,19,2),
(1013,21,1),

(1014,18,2),
(1014,22,1),

(1015,3,2),
(1015,6,2),

(1016,11,2),
(1016,13,2),

(1017,25,2),
(1017,22,1),

(1018,8,2),
(1018,14,1),

(1019,3,3),
(1019,19,1),

(1020,16,2),
(1020,21,2),

(1021,20,1),
(1021,12,2),

(1022,2,2),
(1022,22,1),

(1023,3,2),
(1023,13,1),

(1024,6,1),
(1024,21,1),

(1025,5,2),
(1025,14,1),

(1026,7,2),
(1026,22,1),

(1027,18,2),
(1027,13,1),

(1028,10,2),
(1028,21,1),

(1029,3,3),
(1029,22,2),

(1030,1,2),
(1030,14,1),

(1031,23,3),
(1031,15,2),

(1032,24,2),
(1032,13,1),

(1033,19,2),
(1033,22,1),

(1034,18,2),
(1034,21,1),

(1035,3,3),
(1035,6,1),

(1036,11,2),
(1036,14,1),

(1037,25,2),
(1037,22,1),

(1038,8,2),
(1038,13,2),

(1039,3,3),
(1039,19,2),

(1040,16,2),
(1040,21,1),

(1041,20,1),
(1041,12,2),

(1042,2,2),
(1042,22,2),

(1043,3,2),
(1043,6,1),

(1044,18,1),
(1044,21,2),

(1045,5,2),
(1045,15,1),

(1046,19,2),
(1046,22,2),

(1047,7,2),
(1047,13,1),

(1048,10,1),
(1048,21,1),

(1049,3,3),
(1049,6,2),

(1050,2,2),
(1050,22,1);


CREATE TABLE restaurant_employees(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    gender VARCHAR(10),
    age INT,
    designation VARCHAR(50),
    salary DECIMAL(10,2),
    joining_date DATE,
    phone_no VARCHAR(15),
    city VARCHAR(50),
    restaurant_id INT,
    shift_type VARCHAR(20),
    experience_years INT,
    manager_id INT
);



select r.restaurant_name, count(o.order_id) 
from restaurants r inner join  orders o
on r.restaurant_id =o.restaurant_id
group by r.restaurant_name;


select c.customer_name,count(o.order_id)
from customers c inner join orders o
on c.customer_id=o.customer_id
group by c.customer_id
having count(o.order_id)>3;



select p.partner_name,count(o.order_id)
from delivery_partners p inner join orders o
on p.partner_id=o.partner_id
group by p.partner_id;




select c.customer_name,o.order_date,r.restaurant_name
from customers c inner join orders o
on c.customer_id=o.customer_id inner join 
restaurants r on o.restaurant_id=r.restaurant_id;


select r.restaurant_name,count(o.order_id)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name
having count(o.order_id)>=1;


select c.customer_name,count(o.order_id)
from customers c inner join orders o
on c.customer_id=o.customer_id
group by c.customer_name
having count(o.order_id)>=1;


select  r.restaurant_name,o.order_id,r.rating
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id;


select c.customer_name,o.order_id,o.order_amount,o.order_date,r.*
from customers c inner join orders o
on c.customer_id=o.customer_id inner join restaurants r
on o.restaurant_id=r.restaurant_id;


select o.order_id,o.order_amount,o.order_date,r.*
from restaurants r inner join  orders o
on o.restaurant_id=r.restaurant_id
;



21)
select r.restaurant_name,avg(o.order_amount)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name;

22)
select c.customer_name,avg(o.order_amount)
from customers c inner join orders o
on c.customer_id=o.customer_id
group by customer_name; 

23)
select f.item_name,f.price
from order_details o inner join food_items f
on o.item_id=f.item_id
order by f.price desc
limit 1;

24)
select c.customer_name,count(r.restaurant_name)
from customers c inner join orders o
on c.customer_id=o.customer_id inner join restaurants r
on o.restaurant_id=r.restaurant_id
group by c.customer_name
having count(r.restaurant_name)>1;

25)
select r.restaurant_name,count( distinct c.customer_name)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id inner join customers c
on c.customer_id=o.customer_id
group by r.restaurant_name
having count(c.customer_name)>10;

26)
select f.item_name,sum(o.quantity)
from food_items f inner join order_details o
on f.item_id=o.item_id
group by f.item_name;

27)
select r.restaurant_name,count(o.order_id)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name
order by count(o.order_id) desc;

28)
select p.partner_name ,count(o.order_id)
from delivery_partners p inner join orders o
on p.partner_id=o.partner_id
group by p.partner_name
order by count(o.order_id) desc;


29)

select c.customer_name,count(o.order_amount)
from customers c inner join orders o
on c.customer_id= o.customer_id
group by c.customer_name
having count(o.order_amount)>2000
;


30)
select r.restaurant_name,avg(o.order_amount)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name
having avg(o.order_amount)>600;



31)

select c.customer_name,sum(o.order_amount)
from customers c inner join  orders o
on c.customer_id=o.customer_id
group by c.customer_name
having sum(o.order_amount)>(select avg(customer_total) from (select sum(o1.order_amount) as customer_total
from customers c1 inner join  orders o1
on c1.customer_id=o1.customer_id
group by c1.customer_name) as total_salary);


32
select r.restaurant_name,sum(o.order_amount)
from restaurants r inner join orders o
on r.restaurant_id=o.restaurant_id
group by r.restaurant_name
having sum(o.order_amount)>(select avg(total_sal)
from(select sum(o2.order_amount)as total_sal
from restaurants r2 inner join orders o2
on r2.restaurant_id=o2.restaurant_id
group by r2.restaurant_name
)as total_salary);


33)
select c.customer_name,r.restaurant_name,max(r.rating)
from customers c inner join orders o
on c.customer_id=o.customer_id inner join restaurants r on
o.restaurant_id=r.restaurant_id
group by c.customer_name,r.restaurant_name
order by max(r.rating) desc
;


34)

select r.restaurant_name,sum(o.order_amount)
from restaurants r inner join orders o
on r.restaurant_id = o.restaurant_id
group by r.restaurant_name
having sum(o.order_amount)>(select min(total_revenue)
from (select r1.restaurant_name,sum(o1.order_amount) as total_revenue
from restaurants r1 inner join orders o1
on r1.restaurant_id = o1.restaurant_id
group by r1.restaurant_name) as totals);


35)
select f.item_name,sum(o.quantity)
from food_items f inner join order_details o
on f.item_id=o.item_id
group by f.item_name
having sum(o.quantity)>(select avg(total_quantity)
from(select sum(o1.quantity) as total_quantity
from food_items f1 inner join order_details o1
on f1.item_id=o1.item_id
group by f1.item_name) as total);


36)
select c.customer_name,sum(o.order_amount)
from customers c inner join orders o
on c.customer_id =o.customer_id
group by c.customer_name
having sum(o.order_amount)>(select sum(o1.order_amount)		
from customers c1 inner join orders o1
on c1.customer_id =o1.customer_id
group by c1.customer_name




//self join

use s_operator;

desc restaurant_employees;

select * from restaurant_employees;

INSERT INTO restaurant_employees 
(emp_id, emp_name, gender, age, designation, salary, joining_date, phone_no, city, restaurant_id, shift_type, experience_years, manager_id)
VALUES
(1,  'Rajesh Kumar',     'Male',   34, 'Manager',        55000.00, '2018-03-15', '9876543210', 'Bengaluru', 101, 'Day',     10, NULL),
(2,  'Priya Sharma',     'Female', 28, 'Head Chef',       48000.00, '2019-06-01', '9876543211', 'Bengaluru', 101, 'Day',     7,  1),
(3,  'Amit Verma',       'Male',   25, 'Sous Chef',       32000.00, '2020-01-10', '9876543212', 'Bengaluru', 101, 'Day',     4,  2),
(4,  'Sneha Reddy',      'Female', 22, 'Waiter',          18000.00, '2021-05-20', '9876543213', 'Bengaluru', 101, 'Evening', 1,  1),
(5,  'Vikram Singh',     'Male',   30, 'Waiter',          19000.00, '2020-11-11', '9876543214', 'Bengaluru', 101, 'Evening', 3,  1),
(6,  'Anjali Nair',      'Female', 27, 'Cashier',         22000.00, '2019-09-05', '9876543215', 'Chennai',   102, 'Day',     5,  7),
(7,  'Suresh Pillai',    'Male',   40, 'Manager',         56000.00, '2016-02-25', '9876543216', 'Chennai',   102, 'Day',     12, NULL),
(8,  'Divya Menon',      'Female', 24, 'Waiter',          18500.00, '2021-08-14', '9876543217', 'Chennai',   102, 'Night',   2,  7),
(9,  'Karthik Iyer',     'Male',   29, 'Sous Chef',       31000.00, '2020-04-18', '9876543218', 'Chennai',   102, 'Day',     6,  7),
(10, 'Meena Krishnan',   'Female', 35, 'Head Chef',       49000.00, '2017-07-22', '9876543219', 'Chennai',   102, 'Day',     9,  7),
(11, 'Arjun Das',        'Male',   26, 'Bartender',       25000.00, '2020-10-30', '9876543220', 'Mumbai',    103, 'Night',   4,  13),
(12, 'Pooja Joshi',      'Female', 23, 'Waiter',          17500.00, '2021-12-01', '9876543221', 'Mumbai',    103, 'Evening', 1,  13),
(13, 'Rohan Mehta',      'Male',   38, 'Manager',         57000.00, '2015-05-09', '9876543222', 'Mumbai',    103, 'Day',     13, NULL),
(14, 'Kavita Iyer',      'Female', 31, 'Head Chef',       50000.00, '2018-09-17', '9876543223', 'Mumbai',    103, 'Day',     8,  13),
(15, 'Sandeep Rao',      'Male',   33, 'Cashier',         23000.00, '2019-03-03', '9876543224', 'Hyderabad', 104, 'Day',     6,  17),
(16, 'Lakshmi Pillai',   'Female', 21, 'Waiter',          17000.00, '2022-01-25', '9876543225', 'Hyderabad', 104, 'Evening', 1,  17),
(17, 'Manoj Tiwari',     'Male',   42, 'Manager',         58000.00, '2014-11-12', '9876543226', 'Hyderabad', 104, 'Day',     15, NULL),
(18, 'Swathi Raju',      'Female', 26, 'Sous Chef',       30500.00, '2020-06-28', '9876543227', 'Hyderabad', 104, 'Day',     5,  17),
(19, 'Deepak Chauhan',   'Male',   29, 'Bartender',       24500.00, '2020-02-14', '9876543228', 'Pune',      105, 'Night',   4,  20),
(20, 'Ritu Kapoor',      'Female', 36, 'Manager',         55500.00, '2017-04-07', '9876543229', 'Pune',      105, 'Day',     11, NULL);




select e.emp_name as employee_name,e.emp_id as employee_id,m.emp_name as mgr_name,m.emp_id as mgr_id
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id;


select e.emp_name as employee_name,e.joining_date as employee_hiredate,m.emp_name as manager_name,m.joining_date as manager_hiredate
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where e.joining_date < m.joining_date;



select e.emp_name as employee_name,e.age as employee_age,e.salary as employee_salary, m.emp_name as manager_name,m.age as manager_age,m.salary as manager_salary
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where length(substring(e.emp_name,instr(e.emp_name,' ')+1))>length(substring(m.emp_name,instr(m.emp_name,' ')+1))
and e.age>m.age;


select e.emp_name as employee_name,e.designation as employee_designation,m.emp_name as manager_name,m.designation as manager_designation
from restaurant_employees e join  restaurant_employees m
on e.manager_id=m.emp_id
where e.designation != m.designation and 
substr(e.emp_name,1,1) in('A','E','I','O','U') and

substr(m.emp_name,1,1) in('A','E','I','O','U') and 
substr(e.designation,length(e.designation),1) not in('a','e','i','o','u')  and
substr(m.designation,length(m.designation),1)  not in('a','e','i','o','u') ;


select e.emp_name as employee_name,e.shift_type as employee_shift_type,m.emp_name as manager_name,m.shift_type as manager_shift_type
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where e.shift_type=m.shift_type and e.salary >60000 and m.salary >65000 and e.designation=m.designation and e.joining_date=m.joining_date;

select e.emp_name as employee_name,e.emp_id as employee_id,m.emp_name  as manager_name,m.emp_id as manager_id
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where m.salary=(select max(n.salary)
from restaurant_employees n
where n.salary<(select max(n.salary)
from restaurant_employees n));

select e.emp_name as employee_name,e.city as employee_location,m.city as manager_location
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where e.city=m.city and e.shift_type != m.shift_type and substring(e.designation,length(e.designation),1)=substring(m.designation,length(m.designation),1)  and
substring(e.emp_name,1,1)=substring(m.emp_name,1) and e.salary between 60000 and 90000  and m.salary between 70000 and 100000; 


select e.emp_name as employee_name,e.joining_date as employee_hiredate,e.salary as employee_salary,e.age as employee_age,e.shift_type as employee_shift_type,
m.emp_name as manager_name,m.joining_date as manager_hiredate,m.salary as manager_salary,m.age as manager_age,m.shift_type as manager_shift_type
from restaurant_employees e join restaurant_employees m
on e.manager_id=m.emp_id
where e.joining_date=m.joining_date and
length(e.emp_name)=length(m.emp_name) and
length(e.designation)=length(m.designation) and
length(substring(e.emp_name,1,instr(e.emp_name,'')-1))>4;


use s_operator;

select * from food_items;

select food_items.*,
row_number()over(partition by item_name order  by price desc)as rownumber
from food_items;

use s_operator;
select *
from food_items;
                   
                   
                                                                                                                                                                                                                                                                                                                                                                                                                                                      0
      Create table
CREATE TABLE sales_data (
    sale_id INT PRIMARY KEY,
    salesperson VARCHAR(50),
    region VARCHAR(30),
    product_category VARCHAR(30),
    product_name VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    sale_date DATE,
    revenue DECIMAL(10,2)
);                                                                                                                                                                                                                                                                                                                                                                                                                                                
     INSERT INTO sales_data (sale_id, salesperson, region, product_category, product_name, quantity, unit_price, sale_date, revenue) VALUES
(1,  'Alice',   'North', 'Electronics', 'Laptop',      2, 55000.00, '2024-01-05', 110000.00),
(2,  'Alice',   'North', 'Electronics', 'Mouse',       5,   500.00, '2024-01-08',   2500.00),
(3,  'Bob',     'North', 'Furniture',   'Chair',       3,  3000.00, '2024-01-10',   9000.00),
(4,  'Bob',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-01-15',   8000.00),
(5,  'Charlie', 'South', 'Electronics', 'Laptop',      1, 55000.00, '2024-01-06',  55000.00),
(6,  'Charlie', 'South', 'Electronics', 'Keyboard',    4,  1200.00, '2024-01-09',   4800.00),
(7,  'David',   'South', 'Furniture',   'Chair',       3,  3000.00, '2024-01-11',   9000.00),
(8,  'David',   'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-01-20',  25000.00),
(9,  'Eva',     'East',  'Electronics', 'Laptop',      3, 55000.00, '2024-02-01', 165000.00),
(10, 'Eva',     'East',  'Electronics', 'Monitor',     2,  9000.00, '2024-02-03',  18000.00),
(11, 'Frank',   'East',  'Furniture',   'Desk',        2,  8000.00, '2024-02-05',  16000.00),
(12, 'Frank',   'East',  'Furniture',   'Chair',       6,  3000.00, '2024-02-07',  18000.00),
(13, 'Grace',   'West',  'Electronics', 'Mouse',      10,   500.00, '2024-02-10',   5000.00),
(14, 'Grace',   'West',  'Electronics', 'Keyboard',    3,  1200.00, '2024-02-12',   3600.00),
(15, 'Helen',   'West',  'Furniture',   'Sofa',        2, 25000.00, '2024-02-15',  50000.00),
(16, 'Helen',   'West',  'Furniture',   'Chair',       4,  3000.00, '2024-02-18',  12000.00),
(17, 'Ian',     'North', 'Electronics', 'Laptop',      1, 55000.00, '2024-03-01',  55000.00),
(18, 'Ian',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-03-03',   8000.00),
(19, 'Jack',    'South', 'Electronics', 'Monitor',     3,  9000.00, '2024-03-05',  27000.00),
(20, 'Jack',    'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-03-08',  25000.00);                                                                                                                                                                                                                                                                                                                                                                                                                                                 ....
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                               INSERT INTO sales_data (sale_id, salesperson, region, product_category, product_name, quantity, unit_price, sale_date, revenue) VALUES
(1,  'Alice',   'North', 'Electronics', 'Laptop',      2, 55000.00, '2024-01-05', 110000.00),
(2,  'Alice',   'North', 'Electronics', 'Mouse',       5,   500.00, '2024-01-08',   2500.00),
(3,  'Bob',     'North', 'Furniture',   'Chair',       3,  3000.00, '2024-01-10',   9000.00),
(4,  'Bob',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-01-15',   8000.00),
(5,  'Charlie', 'South', 'Electronics', 'Laptop',      1, 55000.00, '2024-01-06',  55000.00),
(6,  'Charlie', 'South', 'Electronics', 'Keyboard',    4,  1200.00, '2024-01-09',   4800.00),
(7,  'David',   'South', 'Furniture',   'Chair',       3,  3000.00, '2024-01-11',   9000.00),
(8,  'David',   'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-01-20',  25000.00),
(9,  'Eva',     'East',  'Electronics', 'Laptop',      3, 55000.00, '2024-02-01', 165000.00),
(10, 'Eva',     'East',  'Electronics', 'Monitor',     2,  9000.00, '2024-02-03',  18000.00),
(11, 'Frank',   'East',  'Furniture',   'Desk',        2,  8000.00, '2024-02-05',  16000.00),
(12, 'Frank',   'East',  'Furniture',   'Chair',       6,  3000.00, '2024-02-07',  18000.00),
(13, 'Grace',   'West',  'Electronics', 'Mouse',      10,   500.00, '2024-02-10',   5000.00),
(14, 'Grace',   'West',  'Electronics', 'Keyboard',    3,  1200.00, '2024-02-12',   3600.00),
(15, 'Helen',   'West',  'Furniture',   'Sofa',        2, 25000.00, '2024-02-15',  50000.00),
(16, 'Helen',   'West',  'Furniture',   'Chair',       4,  3000.00, '2024-02-18',  12000.00),
(17, 'Ian',     'North', 'Electronics', 'Laptop',      1, 55000.00, '2024-03-01',  55000.00),
(18, 'Ian',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-03-03',   8000.00),
(19, 'Jack',    'South', 'Electronics', 'Monitor',     3,  9000.00, '2024-03-05',  27000.00),
(20, 'Jack',    'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-03-08',  25000.00);                                                                                                                                                                                                                                                                                                                                                                                                                       
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                                      
          truncate table sales_data;        
          00
INSERT INTO sales_data (sale_id, salesperson, region, product_category, product_name, quantity, unit_price, sale_date, revenue) VALUES
(1,  'Alice',   'North', 'Electronics', 'Laptop',      2, 55000.00, '2024-01-05', 110000.00),
(2,  'Alice',   'North', 'Electronics', 'Mouse',       5,   500.00, '2024-01-08',   2500.00),
(3,  'Bob',     'North', 'Furniture',   'Chair',       3,  3000.00, '2024-01-10',   9000.00),
(4,  'Bob',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-01-15',   8000.00),
(5,  'Charlie', 'South', 'Electronics', 'Laptop',      1, 55000.00, '2024-01-06',  55000.00),
(6,  'Charlie', 'South', 'Electronics', 'Keyboard',    4,  1200.00, '2024-01-09',   4800.00),
(7,  'David',   'South', 'Furniture',   'Chair',       3,  3000.00, '2024-01-11',   9000.00),
(8,  'David',   'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-01-20',  25000.00),
(9,  'Eva',     'East',  'Electronics', 'Laptop',      3, 55000.00, '2024-02-01', 165000.00),
(10, 'Eva',     'East',  'Electronics', 'Monitor',     2,  9000.00, '2024-02-03',  18000.00),
(11, 'Frank',   'East',  'Furniture',   'Desk',        2,  8000.00, '2024-02-05',  16000.00),
(12, 'Frank',   'East',  'Furniture',   'Chair',       6,  3000.00, '2024-02-07',  18000.00),
(13, 'Grace',   'West',  'Electronics', 'Mouse',      10,   500.00, '2024-02-10',   5000.00),
(14, 'Grace',   'West',  'Electronics', 'Keyboard',    3,  1200.00, '2024-02-12',   3600.00),
(15, 'Helen',   'West',  'Furniture',   'Sofa',        2, 25000.00, '2024-02-15',  50000.00),
(16, 'Helen',   'West',  'Furniture',   'Chair',       4,  3000.00, '2024-02-18',  12000.00),
(17, 'Ian',     'North', 'Electronics', 'Laptop',      1, 55000.00, '2024-03-01',  55000.00),
(18, 'Ian',     'North', 'Furniture',   'Desk',        1,  8000.00, '2024-03-03',   8000.00),
(19, 'Jack',    'South', 'Electronics', 'Monitor',     3,  9000.00, '2024-03-05',  27000.00),
(20, 'Jack',    'South', 'Furniture',   'Sofa',        1, 25000.00, '2024-03-08',  25000.00);




select sales_data.*,row_number() over(order by revenue desc)as ranked
from sales_data;

select sales_data.*,row_number() over(partition by region order by revenue desc)as ranked
from sales_data;


select sales_data.*,rank() over(order by revenue desc)as ranked
from sales_data;


select sales_data.*,dense_rank() over(order by revenue desc)as ranked
from sales_data;

select sale_id,revenue,ntile(30)over(order by revenue desc)as bucket_number,row_number() over(order by revenue desc)as row_num
from sales_data;


select sales_data.*,sum(revenue) over(order by revenue desc rows between unbounded preceding and  unbounded following) as first_last
from sales_data;


select sales_data.*,sum(revenue) over(order by revenue desc rows between unbounded preceding and  current row) as first_last
from sales_data;
use s_operator;
elect sales_data.*,sum(revenue) over(order by revenue desc rows between   current row and unbounded preceding ) as first_last
from sales_data;
s




select sales_data.*,sum(revenue) over(partition by product_category order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,avg(revenue) over(partition by product_category order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,count(revenue) over(partition by product_category order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;


select sales_data.*,min(revenue) over(partition by product_category order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

-//function without the partition  by//- 

select sales_data.*,sum(revenue) over( order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,min(revenue) over( order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,max(revenue) over( order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,count(revenue) over(order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;

select sales_data.*,avg(revenue) over(order by revenue rows between unbounded  preceding  and unbounded following ) as wfunction
from sales_data;


rows between unbounded preceding and current row

select sales_data.*,min(revenue) over(partition by product_category order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,max(revenue) over(partition by product_category order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,avg(revenue) over(partition by product_category order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,count(revenue) over(partition by product_category order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,sum(revenue) over(partition by product_category order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;

without partion by
select sales_data.*,min(revenue) over( order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,max(revenue) over(order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,avg(revenue) over(order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,count(revenue) over(order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;
select sales_data.*,sum(revenue) over(order by revenue rows between unbounded preceding and current row ) as wfunction
from sales_data;


rows between current row and unbounded following

select sales_data.*,sum(revenue) over(partition by product_category order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,max(revenue) over(partition by product_category order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,min(revenue) over(partition by product_category order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,count(revenue) over(partition by product_category order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,avg(revenue) over(partition by product_category order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;

withpout partition by


select sales_data.*,sum(revenue) over(order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,max(revenue) over(order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,min(revenue) over(order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,count(revenue) over(order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;
select sales_data.*,avg(revenue) over(order by revenue rows between current row and unbounded following ) as wfunction
from sales_data;


use s_operator;

CREATE TABLE employee_sales1 (
    emp_id        INT PRIMARY KEY,
    emp_name      VARCHAR(50),
    department    VARCHAR(20),
    region        VARCHAR(20),
    job_title     VARCHAR(30),
    hire_date     DATE,
    salary        DECIMAL(10,2),
    bonus         DECIMAL(10,2),
    sales_amount  DECIMAL(10,2),
    quarter       VARCHAR(2)
);

INSERT INTO employee_sales1
(emp_id, emp_name, department, region, job_title, hire_date, salary, bonus, sales_amount, quarter)
VALUES
(1,  'Alice Johnson',  'Sales',   'East', 'Sales Rep',     '2019-03-15', 55000, 4000, 120000, 'Q1'),
(2,  'Brian Smith',    'Sales',   'East', 'Sales Rep',     '2020-06-10', 52000, 3500, 95000,  'Q1'),
(3,  'Catherine Lee',  'Sales',   'West', 'Sales Rep',     '2018-01-22', 58000, 4500, 130000, 'Q1'),
(4,  'David Kim',      'Sales',   'West', 'Sales Rep',     '2021-09-05', 50000, 3000, 87000,  'Q1'),
(5,  'Emma Wilson',    'Sales',   'East', 'Sales Manager', '2016-11-30', 72000, 6000, 150000, 'Q1'),
(6,  'Frank Torres',   'Sales',   'West', 'Sales Manager', '2017-04-18', 74000, 6500, 160000, 'Q1'),
(7,  'Grace Chen',     'IT',      'East', 'Developer',     '2019-07-01', 68000, 3000, 0,      'Q1'),
(8,  'Henry Patel',    'IT',      'East', 'Developer',     '2020-02-14', 65000, 2800, 0,      'Q1'),
(9,  'Isla Brown',     'IT',      'West', 'Developer',     '2018-10-09', 70000, 3200, 0,      'Q1'),
(10, 'Jack Davis',     'IT',      'West', 'Team Lead',     '2015-05-20', 85000, 7000, 0,      'Q1'),
(11, 'Karen White',    'HR',      'East', 'HR Executive',  '2019-01-11', 48000, 2000, 0,      'Q1'),
(12, 'Liam Green',     'HR',      'West', 'HR Manager',    '2017-08-25', 62000, 4000, 0,      'Q1'),
(13, 'Mia Roberts',    'Finance', 'East', 'Analyst',       '2020-03-30', 60000, 2500, 0,      'Q1'),
(14, 'Noah Turner',    'Finance', 'West', 'Analyst',       '2019-12-05', 61000, 2600, 0,      'Q1'),
(15, 'Olivia Scott',   'Finance', 'East', 'Finance Manager','2016-06-17', 80000, 6000, 0,     'Q1'),
(16, 'Alice Johnson',  'Sales',   'East', 'Sales Rep',     '2019-03-15', 55000, 4200, 128000, 'Q2'),
(17, 'Brian Smith',    'Sales',   'East', 'Sales Rep',     '2020-06-10', 52000, 3600, 99000,  'Q2'),
(18, 'Catherine Lee',  'Sales',   'West', 'Sales Rep',     '2018-01-22', 58000, 4700, 135000, 'Q2'),
(19, 'David Kim',      'Sales',   'West', 'Sales Rep',     '2021-09-05', 50000, 3100, 91000,  'Q2'),
(20, 'Emma Wilson',    'Sales',   'East', 'Sales Manager', '2016-11-30', 72000, 6200, 155000, 'Q2'),
(21, 'Frank Torres',   'Sales',   'West', 'Sales Manager', '2017-04-18', 74000, 6700, 158000, 'Q2'),
(22, 'Grace Chen',     'IT',      'East', 'Developer',     '2019-07-01', 68000, 3100, 0,      'Q2'),
(23, 'Henry Patel',    'IT',      'East', 'Developer',     '2020-02-14', 65000, 2900, 0,      'Q2'),
(24, 'Isla Brown',     'IT',      'West', 'Developer',     '2018-10-09', 70000, 3300, 0,      'Q2'),
(25, 'Jack Davis',     'IT',      'West', 'Team Lead',     '2015-05-20', 85000, 7200, 0,      'Q2'),
(26, 'Karen White',    'HR',      'East', 'HR Executive',  '2019-01-11', 48000, 2100, 0,      'Q2'),
(27, 'Liam Green',     'HR',      'West', 'HR Manager',    '2017-08-25', 62000, 4100, 0,      'Q2'),
(28, 'Mia Roberts',    'Finance', 'East', 'Analyst',       '2020-03-30', 60000, 2550, 0,      'Q2'),
(29, 'Noah Turner',    'Finance', 'West', 'Analyst',       '2019-12-05', 61000, 2650, 0,      'Q2'),
(30, 'Olivia Scott',   'Finance', 'East', 'Finance Manager','2016-06-17', 80000, 6100, 0,     'Q2'),
(31, 'Alice Johnson',  'Sales',   'East', 'Sales Rep',     '2019-03-15', 56000, 4300, 132000, 'Q3'),
(32, 'Brian Smith',    'Sales',   'East', 'Sales Rep',     '2020-06-10', 53000, 3700, 101000, 'Q3'),
(33, 'Catherine Lee',  'Sales',   'West', 'Sales Rep',     '2018-01-22', 59000, 4800, 140000, 'Q3'),
(34, 'David Kim',      'Sales',   'West', 'Sales Rep',     '2021-09-05', 51000, 3200, 93000,  'Q3'),
(35, 'Emma Wilson',    'Sales',   'East', 'Sales Manager', '2016-11-30', 73000, 6300, 162000, 'Q3'),
(36, 'Frank Torres',   'Sales',   'West', 'Sales Manager', '2017-04-18', 75000, 6800, 165000, 'Q3'),
(37, 'Grace Chen',     'IT',      'East', 'Developer',     '2019-07-01', 69000, 3200, 0,      'Q3'),
(38, 'Henry Patel',    'IT',      'East', 'Developer',     '2020-02-14', 66000, 3000, 0,      'Q3'),
(39, 'Isla Brown',     'IT',      'West', 'Developer',     '2018-10-09', 71000, 3400, 0,      'Q3'),
(40, 'Jack Davis',     'IT',      'West', 'Team Lead',     '2015-05-20', 86000, 7300, 0,      'Q3');


select employee_sales1.*,last_value(region)over(order by salary asc  rows between unbounded preceding and current row)as ranked
from employee_sales1; 
select employee_sales1.*,last_value(region)over(order by salary asc )as ranked
from employee_sales1; 

select * from employee_sales1;


select employee_sales1.*,last_value(region)over(order by salary asc  rows between unbounded preceding and unbounded following)as ranked
from employee_sales1; 
 
 
 select * from employee_sales1;


select employee_sales1.*,nth_value(hire_date,4)over (partition by department order by bonus asc rows between unbounded preceding and unbounded following) as ranked
from employee_sales1;

select * from employees; 


desc employees;

select * from employees;
desc employees;

use s_operator;
create table employees_copy
like employees;
desc employees_copy;
insert into employees_copy
 select * from employees;
   
use s_operator;create table employee_copy1 as
select * from employees
where salary>50000;

select * from employees_copy1;
select * from employees;

use s_operator;
create table managers
as select e1.*,e2.manager_id as mid
from employees e1 join employees e2
on e1.emp_id=e2.manager_id; 


create table employee_copy3
as select emp_name,age,department from employees;

select * from employee_copy3;

use s_operator;
create table employee_copy4
as select emp_name,salary,age,department
from employees
where salary>40000;


create table employee_copy4
as select e1.emp_name,e1.salary,e2.emp_name as managers_name,e2.salary as managers_salary
from employees e1 join employees e2
on e1.manager_id=e2.emp_id where  e2.salary>e1.salary;

-- select * from employee_copy4;
use s_operator;
insert into employee_copy4(emp_name,Salary,age,department) select emp_name,Salary,age,department from employee_copy4 where age=30;
 
create database case1;
use case1;
create table employee_performance (
    emp_id int primary key,
    emp_name varchar(50),
    department varchar(30),
    city varchar(30),
    experience int,
    salary decimal(10,2),
    performance_score int
);


insert into employee_performance values
(101,'Rahul','IT','Bangalore',2,35000,65),
(102,'Priya','HR','Delhi',6,55000,82),
(103,'Amit','Finance','Mumbai',10,70000,94),
(104,'Sneha','IT','Hyderabad',4,50000,75),
(105,'Karan','Sales','Chennai',1,28000,58),
(106,'Pooja','HR','Bangalore',8,72000,89),
(107,'Vikas','Finance','Delhi',12,90000,97),
(108,'Neena','Sales','Mumbai',3,42000,69),
(109,'Rohit','IT','Pune',7,73000,91),
(110,'Deepak','Finance','Hyderabad',5,61000,80),
(111,'Meena','Sales','Delhi',9,64000,85),
(112,'Arjun','HR','Chennai',2,39000,63),
(113,'Kavya','IT','Mumbai',11,85000,95),
(114,'Anil','Finance','Bangalore',6,62000,84),
(115,'Divya','Sales','Hyderabad',4,48000,72),
(116,'Manoj','IT','Delhi',13,95000,98),
(117,'Swathi','HR','Pune',5,56000,79),
(118,'Ajay','Finance','Chennai',7,69000,88),
(119,'Nisha','Sales','Bangalore',1,31000,60),
(120,'Suresh','IT','Mumbai',9,81000,93),
(121,'Ramesh','Finance','Delhi',8,76000,90),
(122,'Lakshmi','HR','Hyderabad',3,43000,70),
(123,'Girish','Sales','Pune',6,59000,81),
(124,'Asha','IT','Chennai',4,52000,76),
(125,'Vinod','Finance','Bangalore',10,88000,96),
(126,'Bhavana','HR','Mumbai',2,37000,67),
(127,'Harish','Sales','Delhi',5,54000,78),
(128,'Keerthi','IT','Hyderabad',7,71000,87),
(129,'Naveen','Finance','Pune',11,92000,99),
(130,'Shilpa','HR','Bangalore',4,51000,74);











select * from employee_performance;
select emp_id,emp_name,department,city,
case department
     when 'IT' then 'Software'
     when 'HR'  then 'operations'
     when 'Sales'  then   'selling'
     when 'Finance'  then   'Money maintain'
	 else 'no result found'
end
as cases
from employee_performance;
select emp_name,department,city,case city when 'Bangalore' then 'Karnataka'
										when 'Chennai' then 'Tamilnadu'
												when 'Hyderabad' then 'Ap'
                                                when 'Mumbai' then 'Maharashtra'
                                                when 'Pune' then 'Pune'
                                                when 'Delhi' then 'Delhi'
										else 'no state '
                                        end as cases
from employee_performance;



select emp_id,emp_name,salary,
case when salary>80000 THEN 'High_salary'
 when salary between 50000 AND 80000 then 'medium_salary'
else 'loww salary' END as salary_category
from employee_performance;


Select emp_id, emp_name,experience,
case WHEN experience between 0 and 2 THEN 'fresher'
when experience BETWEEN 3 and 6 then 'intermediate'
WHEN experience between 7 AND 10 then 'senior'
ELSE 'expert' end AS experience_level
FROM employee_performance;


select emp_id,emp_name, performance_score,
CASE WHEN performance_score >=90 then 'Grade A'
WHEN performance_score BETWEEN 80 and 89 THEN 'Grade B'
when performance_score between 70 AND 79 then 'Grade C'
ELSE 'needs improvement' END as performance_grade
FROM employee_performance;


SELECT emp_id,emp_name,performance_score,salary,
case WHEN performance_score>=85 AND salary<90000 THEN 'Eligible'
ELSE 'not eligible' end as bonus_eligibility
from employee_performance;



SELECT * from employee_performance
WHERE(case when salary>80000 then 'High Salary'
when salary between 50000 and 80000 then 'Medium Salary'
ELSE 'Low Salary' end)='High Salary';


select * FROM employee_performance
where(case when experience BETWEEN 0 and 2 then 'Fresher'
WHEN experience between 3 AnD 6 then 'intermediate'
when experience between 7 and 10 then 'senior'
ELSE 'expert' END)='expert';


SELECT * FROM employee_performance
where(CASE WHEN performance_score>=90 THEN 'A'
when performance_score BETWEEN 80 and 89 then 'B'
WHEN performance_score between 70 AND 79 then 'C'
else 'Needs Improvement' end) IN('A','B');



select case when salary>80000 then'High Salary'
when salary between 50000 and 80000 then 'Medium Salary'
else 'Low Salary' end aS salary_category,
count(*) as emp_count
from employee_performance
group by salary_category;

select case when salary>80000 then 'High Salary'
when salary between 50000 and 80000 then 'Medium Salary'
ELSE 'Low Salary' end AS salary_category,
COUNT(*) as emp_count
FROM employee_performance
GROUP by (case WHEN salary>80000 then 'High Salary'
when salary  between 50000 and 80000 then 'Medium Salary'
ELSE 'Low Salary' END) ;





select CASE when experience between 0 AND 2 THEN 'Fresher'
WHEN experience BETWEEN 3 and 6 then 'Intermediate'
when experience between 7 AND 10 THEN 'Senior'
ELSE 'Expert' end AS experience_level,
AVG(salary) as avg_salary
FROM employee_performance
group BY experience_level;


SELECT department,
CASE when performance_score>=80 THEN 'Good Performer'
else 'Average Performer' END as performance_category,
count(*) AS emp_count
from employee_performance
GROUP by department,performance_category
ORDER BY department;



select * FROM employee_performance
ORDER by CASE department
WHEN 'IT' then 1
when 'Finance' THEN 2
WHEN 'HR' then 3
when 'Sales' THEN 4
END;


SELECT *,
case WHEN performance_score>=90 THEN 'Grade A'
when performance_score BETWEEN 80 and 89 THEN 'Grade B'
WHEN performance_score between 70 AND 79 then 'Grade C'
ELSE 'Others' end AS grade
from employee_performance
order BY case
WHEN performance_score>=90 then 1
when performance_score BETWEEN 80 and 89 THEN 2
when performance_score between 70 AND 79 then 3
ELSE 4 end;


select *,
CASE when salary>80000 THEN 'High Salary'
WHEN salary between 50000 AND 80000 then 'Medium Salary'
else 'Low Salary' END as salary_category
FROM employee_performance
ORDER by CASE
when salary>80000 THEN 1
WHEN salary between 50000 AND 80000 then 2
ELSE 3 end;



SELECT COUNT(*) as grade_a_count
FROM employee_performance
where performance_score>=90;

select department,
SUM(case WHEN salary>70000 THEN 1 else 0 END) as high_salary_count
FROM employee_performance
GROUP BY department;


SELECT SUM(CASE when salary>80000 THEN salary ELSE 0 end) AS total_high_salary
from employee_performance;


select AVG(CASE WHEN performance_score>=85 AND salary<90000 THEN salary END) as avg_bonus_salary
FROM employee_performance;


select MAX(case when experience>10 then salary end) as highest_expert_salary
from employee_performance;


select city,
sum(CASE when performance_score>80 THEN 1 else 0 END) as high_performer_count
from employee_performance
group bY city;


----class------

select * from employee_performance;

	select *,(case 
	when salary>80000 then 'high salary'
	when salary>50000 and salary <=80000 then 'Medium_salary'
	else 'lowsalary'
	end )as cases from employee_performance 
	where (case 
	when salary>80000 then 'high salary'
	when salary>50000 and salary <=80000 then 'Medium_salary'
	else 'lowsalary'
	end )='high salary';


select * ,(case 
when experience<=2 then 'fresher'
when experience>=3 and experience<=6 then 'intermediate'
when experience >=7 and experience<=10 then 'senior'
else 'expert'
end) as cases from employee_performance
where (case 
when experience<=2 then 'fresher'
when experience>=3 and experience<=6 then 'intermediate'
when experience >=7 and experience<=10 then 'senior'
else 'expert'
end)='expert';


select * from employee_performance 
where (case 
when performance_score >=90 then 'Grade A'
when)



select
sum(case when experience between 0 and 2 THEN 1 else 0 END) as freshers,
sum(CASE when experience>2 then 1 ELSE 0 end) AS experienced_employees
from employee_performance;


use case1;
select * from employee_performance;
create view view_of_ep
as select emp_id,emp_name,department,salary from employee_performance;
update employee_performance
set salary=35001.00 where emp_id=101;

select * from view_of_ep;



CREATE DATABASE hospital_db;
USE hospital_db;

CREATE TABLE departments(
 department_id INT PRIMARY KEY AUTO_INCREMENT,
 department_name VARCHAR(100), floor_no INT, hod_name VARCHAR(100),
 contact_number VARCHAR(20), email VARCHAR(100), total_staff INT, established_year YEAR);

CREATE TABLE doctors(
 doctor_id INT PRIMARY KEY AUTO_INCREMENT,
 first_name VARCHAR(50), last_name VARCHAR(50), gender VARCHAR(10),
 specialization VARCHAR(100), qualification VARCHAR(100), experience INT,
 phone VARCHAR(20), email VARCHAR(100), salary DECIMAL(12,2),
 joining_date DATE, department_id INT, consultation_fee DECIMAL(10,2),
 availability VARCHAR(20), city VARCHAR(50),
 FOREIGN KEY(department_id) REFERENCES departments(department_id));

CREATE TABLE patients(
 patient_id INT PRIMARY KEY AUTO_INCREMENT,
 first_name VARCHAR(50), last_name VARCHAR(50), gender VARCHAR(10),
 dob DATE,blood_group VARCHAR(5),phone VARCHAR(20),email VARCHAR(100),
 address VARCHAR(200),city VARCHAR(50),state VARCHAR(50),
 emergency_contact VARCHAR(20),insurance_provider VARCHAR(100),
 insurance_number VARCHAR(50),registration_date DATE);

CREATE TABLE appointments(
 appointment_id INT PRIMARY KEY AUTO_INCREMENT,
 patient_id INT,doctor_id INT,appointment_date DATE,appointment_time TIME,
 appointment_status VARCHAR(30),consultation_type VARCHAR(30),
 symptoms VARCHAR(300),room_number INT,token_number INT,
 booking_mode VARCHAR(30),created_at DATETIME,
 FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
 FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id));

CREATE TABLE medical_records(
 record_id INT PRIMARY KEY AUTO_INCREMENT,
 patient_id INT,doctor_id INT,diagnosis VARCHAR(300),treatment VARCHAR(300),
 allergies VARCHAR(200),blood_pressure VARCHAR(20),sugar_level VARCHAR(20),
 weight DECIMAL(5,2),height DECIMAL(5,2),visit_date DATE,
 follow_up_date DATE,remarks VARCHAR(300),
 FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
 FOREIGN KEY(doctor_id) REFERENCES doctors(doctor_id));

CREATE TABLE medicines(
 medicine_id INT PRIMARY KEY AUTO_INCREMENT,
 medicine_name VARCHAR(100),manufacturer VARCHAR(100),category VARCHAR(50),
 price DECIMAL(10,2),stock_quantity INT,expiry_date DATE,
 batch_number VARCHAR(50),supplier VARCHAR(100),storage_temperature VARCHAR(50));

CREATE TABLE prescriptions(
 prescription_id INT PRIMARY KEY AUTO_INCREMENT,
 record_id INT,medicine_id INT,dosage VARCHAR(100),duration VARCHAR(100),
 quantity INT,instructions VARCHAR(300),
 FOREIGN KEY(record_id) REFERENCES medical_records(record_id),
 FOREIGN KEY(medicine_id) REFERENCES medicines(medicine_id));

CREATE TABLE billing(
 bill_id INT PRIMARY KEY AUTO_INCREMENT,
 patient_id INT,appointment_id INT,consultation_fee DECIMAL(10,2),
 medicine_cost DECIMAL(10,2),lab_charges DECIMAL(10,2),
 room_charges DECIMAL(10,2),discount DECIMAL(10,2),
 tax DECIMAL(10,2),total_amount DECIMAL(12,2),
 payment_method VARCHAR(30),payment_status VARCHAR(30),billing_date DATE,
 FOREIGN KEY(patient_id) REFERENCES patients(patient_id),
 FOREIGN KEY(appointment_id) REFERENCES appointments(appointment_id));

INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Cardiology',1,'HOD 1','9000000001','dept1@hospital.com',21,2011);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Neurology',2,'HOD 2','9000000002','dept2@hospital.com',22,2012);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Orthopedics',3,'HOD 3','9000000003','dept3@hospital.com',23,2013);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Dermatology',4,'HOD 4','9000000004','dept4@hospital.com',24,2014);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('ENT',5,'HOD 5','9000000005','dept5@hospital.com',25,2015);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Oncology',6,'HOD 6','9000000006','dept6@hospital.com',26,2016);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('Pediatrics',7,'HOD 7','9000000007','dept7@hospital.com',27,2017);
INSERT INTO departments(department_name,floor_no,hod_name,contact_number,email,total_staff,established_year) VALUES('General Medicine',8,'HOD 8','9000000008','dept8@hospital.com',28,2018);
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor1','L1','Male','Spec1','MBBS MD',4,'9800000001','doctor1@mail.com',72500,'2021-01-02',1,520,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor2','L2','Female','Spec2','MBBS MD',5,'9800000002','doctor2@mail.com',75000,'2021-01-03',2,540,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor3','L3','Male','Spec3','MBBS MD',6,'9800000003','doctor3@mail.com',77500,'2021-01-04',3,560,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor4','L4','Female','Spec4','MBBS MD',7,'9800000004','doctor4@mail.com',80000,'2021-01-05',4,580,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor5','L5','Male','Spec5','MBBS MD',8,'9800000005','doctor5@mail.com',82500,'2021-01-06',5,600,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor6','L6','Female','Spec6','MBBS MD',9,'9800000006','doctor6@mail.com',85000,'2021-01-07',6,620,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor7','L7','Male','Spec7','MBBS MD',10,'9800000007','doctor7@mail.com',87500,'2021-01-08',7,640,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor8','L8','Female','Spec8','MBBS MD',11,'9800000008','doctor8@mail.com',90000,'2021-01-09',8,660,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor9','L9','Male','Spec1','MBBS MD',12,'9800000009','doctor9@mail.com',92500,'2021-01-10',1,680,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor10','L10','Female','Spec2','MBBS MD',13,'9800000010','doctor10@mail.com',95000,'2021-01-11',2,700,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor11','L11','Male','Spec3','MBBS MD',14,'9800000011','doctor11@mail.com',97500,'2021-01-12',3,720,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor12','L12','Female','Spec4','MBBS MD',15,'9800000012','doctor12@mail.com',100000,'2021-01-13',4,740,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor13','L13','Male','Spec5','MBBS MD',16,'9800000013','doctor13@mail.com',102500,'2021-01-14',5,760,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor14','L14','Female','Spec6','MBBS MD',17,'9800000014','doctor14@mail.com',105000,'2021-01-15',6,780,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor15','L15','Male','Spec7','MBBS MD',3,'9800000015','doctor15@mail.com',107500,'2021-01-16',7,800,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor16','L16','Female','Spec8','MBBS MD',4,'9800000016','doctor16@mail.com',110000,'2021-01-17',8,820,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor17','L17','Male','Spec1','MBBS MD',5,'9800000017','doctor17@mail.com',112500,'2021-01-18',1,840,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor18','L18','Female','Spec2','MBBS MD',6,'9800000018','doctor18@mail.com',115000,'2021-01-19',2,860,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor19','L19','Male','Spec3','MBBS MD',7,'9800000019','doctor19@mail.com',117500,'2021-01-20',3,880,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor20','L20','Female','Spec4','MBBS MD',8,'9800000020','doctor20@mail.com',120000,'2021-01-21',4,900,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor21','L21','Male','Spec5','MBBS MD',9,'9800000021','doctor21@mail.com',122500,'2021-01-22',5,920,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor22','L22','Female','Spec6','MBBS MD',10,'9800000022','doctor22@mail.com',125000,'2021-01-23',6,940,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor23','L23','Male','Spec7','MBBS MD',11,'9800000023','doctor23@mail.com',127500,'2021-01-24',7,960,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor24','L24','Female','Spec8','MBBS MD',12,'9800000024','doctor24@mail.com',130000,'2021-01-25',8,980,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor25','L25','Male','Spec1','MBBS MD',13,'9800000025','doctor25@mail.com',132500,'2021-01-26',1,1000,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor26','L26','Female','Spec2','MBBS MD',14,'9800000026','doctor26@mail.com',135000,'2021-01-27',2,1020,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor27','L27','Male','Spec3','MBBS MD',15,'9800000027','doctor27@mail.com',137500,'2021-01-28',3,1040,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor28','L28','Female','Spec4','MBBS MD',16,'9800000028','doctor28@mail.com',140000,'2021-01-01',4,1060,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor29','L29','Male','Spec5','MBBS MD',17,'9800000029','doctor29@mail.com',142500,'2021-01-02',5,1080,'Available','Bangalore');
INSERT INTO doctors(first_name,last_name,gender,specialization,qualification,experience,phone,email,salary,joining_date,department_id,consultation_fee,availability,city) VALUES('Doctor30','L30','Female','Spec6','MBBS MD',3,'9800000030','doctor30@mail.com',145000,'2021-01-03',6,1100,'Available','Bangalore');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient1','P1','Male','1991-05-02','O+','9700000001','patient1@mail.com','Address 1','Bangalore','Karnataka','9600000001','Star Health','INS0001','2025-01-02');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient2','P2','Female','1992-05-03','O+','9700000002','patient2@mail.com','Address 2','Bangalore','Karnataka','9600000002','Star Health','INS0002','2025-01-03');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient3','P3','Male','1993-05-04','O+','9700000003','patient3@mail.com','Address 3','Bangalore','Karnataka','9600000003','Star Health','INS0003','2025-01-04');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient4','P4','Female','1994-05-05','O+','9700000004','patient4@mail.com','Address 4','Bangalore','Karnataka','9600000004','Star Health','INS0004','2025-01-05');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient5','P5','Male','1995-05-06','O+','9700000005','patient5@mail.com','Address 5','Bangalore','Karnataka','9600000005','Star Health','INS0005','2025-01-06');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient6','P6','Female','1996-05-07','O+','9700000006','patient6@mail.com','Address 6','Bangalore','Karnataka','9600000006','Star Health','INS0006','2025-01-07');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient7','P7','Male','1997-05-08','O+','9700000007','patient7@mail.com','Address 7','Bangalore','Karnataka','9600000007','Star Health','INS0007','2025-01-08');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient8','P8','Female','1998-05-09','O+','9700000008','patient8@mail.com','Address 8','Bangalore','Karnataka','9600000008','Star Health','INS0008','2025-01-09');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient9','P9','Male','1999-05-10','O+','9700000009','patient9@mail.com','Address 9','Bangalore','Karnataka','9600000009','Star Health','INS0009','2025-01-10');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient10','P10','Female','1990-05-11','O+','9700000010','patient10@mail.com','Address 10','Bangalore','Karnataka','9600000010','Star Health','INS0010','2025-01-11');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient11','P11','Male','1991-05-12','O+','9700000011','patient11@mail.com','Address 11','Bangalore','Karnataka','9600000011','Star Health','INS0011','2025-01-12');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient12','P12','Female','1992-05-13','O+','9700000012','patient12@mail.com','Address 12','Bangalore','Karnataka','9600000012','Star Health','INS0012','2025-01-13');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient13','P13','Male','1993-05-14','O+','9700000013','patient13@mail.com','Address 13','Bangalore','Karnataka','9600000013','Star Health','INS0013','2025-01-14');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient14','P14','Female','1994-05-15','O+','9700000014','patient14@mail.com','Address 14','Bangalore','Karnataka','9600000014','Star Health','INS0014','2025-01-15');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient15','P15','Male','1995-05-16','O+','9700000015','patient15@mail.com','Address 15','Bangalore','Karnataka','9600000015','Star Health','INS0015','2025-01-16');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient16','P16','Female','1996-05-17','O+','9700000016','patient16@mail.com','Address 16','Bangalore','Karnataka','9600000016','Star Health','INS0016','2025-01-17');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient17','P17','Male','1997-05-18','O+','9700000017','patient17@mail.com','Address 17','Bangalore','Karnataka','9600000017','Star Health','INS0017','2025-01-18');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient18','P18','Female','1998-05-19','O+','9700000018','patient18@mail.com','Address 18','Bangalore','Karnataka','9600000018','Star Health','INS0018','2025-01-19');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient19','P19','Male','1999-05-20','O+','9700000019','patient19@mail.com','Address 19','Bangalore','Karnataka','9600000019','Star Health','INS0019','2025-01-20');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient20','P20','Female','1990-05-21','O+','9700000020','patient20@mail.com','Address 20','Bangalore','Karnataka','9600000020','Star Health','INS0020','2025-01-21');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient21','P21','Male','1991-05-22','O+','9700000021','patient21@mail.com','Address 21','Bangalore','Karnataka','9600000021','Star Health','INS0021','2025-01-22');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient22','P22','Female','1992-05-23','O+','9700000022','patient22@mail.com','Address 22','Bangalore','Karnataka','9600000022','Star Health','INS0022','2025-01-23');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient23','P23','Male','1993-05-24','O+','9700000023','patient23@mail.com','Address 23','Bangalore','Karnataka','9600000023','Star Health','INS0023','2025-01-24');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient24','P24','Female','1994-05-25','O+','9700000024','patient24@mail.com','Address 24','Bangalore','Karnataka','9600000024','Star Health','INS0024','2025-01-25');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient25','P25','Male','1995-05-26','O+','9700000025','patient25@mail.com','Address 25','Bangalore','Karnataka','9600000025','Star Health','INS0025','2025-01-26');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient26','P26','Female','1996-05-27','O+','9700000026','patient26@mail.com','Address 26','Bangalore','Karnataka','9600000026','Star Health','INS0026','2025-01-27');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient27','P27','Male','1997-05-28','O+','9700000027','patient27@mail.com','Address 27','Bangalore','Karnataka','9600000027','Star Health','INS0027','2025-01-28');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient28','P28','Female','1998-05-01','O+','9700000028','patient28@mail.com','Address 28','Bangalore','Karnataka','9600000028','Star Health','INS0028','2025-01-01');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient29','P29','Male','1999-05-02','O+','9700000029','patient29@mail.com','Address 29','Bangalore','Karnataka','9600000029','Star Health','INS0029','2025-01-02');
INSERT INTO patients(first_name,last_name,gender,dob,blood_group,phone,email,address,city,state,emergency_contact,insurance_provider,insurance_number,registration_date) VALUES('Patient30','P30','Female','1990-05-03','O+','9700000030','patient30@mail.com','Address 30','Bangalore','Karnataka','9600000030','Star Health','INS0030','2025-01-03');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(1,1,'2025-02-02','10:01:00','Completed','OPD','Fever',10,101,'Online','2025-02-02 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(2,2,'2025-02-03','10:02:00','Completed','OPD','Fever',10,102,'Online','2025-02-03 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(3,3,'2025-02-04','10:03:00','Completed','OPD','Fever',10,103,'Online','2025-02-04 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(4,4,'2025-02-05','10:04:00','Completed','OPD','Fever',10,104,'Online','2025-02-05 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(5,5,'2025-02-06','10:05:00','Completed','OPD','Fever',10,105,'Online','2025-02-06 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(6,6,'2025-02-07','10:06:00','Completed','OPD','Fever',10,106,'Online','2025-02-07 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(7,7,'2025-02-08','10:07:00','Completed','OPD','Fever',10,107,'Online','2025-02-08 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(8,8,'2025-02-09','10:08:00','Completed','OPD','Fever',10,108,'Online','2025-02-09 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(9,9,'2025-02-10','10:09:00','Completed','OPD','Fever',10,109,'Online','2025-02-10 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(10,10,'2025-02-11','10:10:00','Completed','OPD','Fever',10,110,'Online','2025-02-11 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(11,11,'2025-02-12','10:11:00','Completed','OPD','Fever',10,111,'Online','2025-02-12 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(12,12,'2025-02-13','10:12:00','Completed','OPD','Fever',10,112,'Online','2025-02-13 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(13,13,'2025-02-14','10:13:00','Completed','OPD','Fever',10,113,'Online','2025-02-14 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(14,14,'2025-02-15','10:14:00','Completed','OPD','Fever',10,114,'Online','2025-02-15 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(15,15,'2025-02-16','10:15:00','Completed','OPD','Fever',10,115,'Online','2025-02-16 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(16,16,'2025-02-17','10:16:00','Completed','OPD','Fever',10,116,'Online','2025-02-17 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(17,17,'2025-02-18','10:17:00','Completed','OPD','Fever',10,117,'Online','2025-02-18 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(18,18,'2025-02-19','10:18:00','Completed','OPD','Fever',10,118,'Online','2025-02-19 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(19,19,'2025-02-20','10:19:00','Completed','OPD','Fever',10,119,'Online','2025-02-20 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(20,20,'2025-02-21','10:20:00','Completed','OPD','Fever',10,120,'Online','2025-02-21 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(21,21,'2025-02-22','10:21:00','Completed','OPD','Fever',10,121,'Online','2025-02-22 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(22,22,'2025-02-23','10:22:00','Completed','OPD','Fever',10,122,'Online','2025-02-23 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(23,23,'2025-02-24','10:23:00','Completed','OPD','Fever',10,123,'Online','2025-02-24 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(24,24,'2025-02-25','10:24:00','Completed','OPD','Fever',10,124,'Online','2025-02-25 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(25,25,'2025-02-26','10:25:00','Completed','OPD','Fever',10,125,'Online','2025-02-26 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(26,26,'2025-02-27','10:26:00','Completed','OPD','Fever',10,126,'Online','2025-02-27 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(27,27,'2025-02-28','10:27:00','Completed','OPD','Fever',10,127,'Online','2025-02-28 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(28,28,'2025-02-01','10:28:00','Completed','OPD','Fever',10,128,'Online','2025-02-01 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(29,29,'2025-02-02','10:29:00','Completed','OPD','Fever',10,129,'Online','2025-02-02 09:00:00');
INSERT INTO appointments(patient_id,doctor_id,appointment_date,appointment_time,appointment_status,consultation_type,symptoms,room_number,token_number,booking_mode,created_at) VALUES(30,30,'2025-02-03','10:30:00','Completed','OPD','Fever',10,130,'Online','2025-02-03 09:00:00');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(1,1,'Diagnosis 1','Treatment 1','None','120/80','95',56,161,'2025-02-02','2025-03-02','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(2,2,'Diagnosis 2','Treatment 2','None','120/80','95',57,162,'2025-02-03','2025-03-03','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(3,3,'Diagnosis 3','Treatment 3','None','120/80','95',58,163,'2025-02-04','2025-03-04','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(4,4,'Diagnosis 4','Treatment 4','None','120/80','95',59,164,'2025-02-05','2025-03-05','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(5,5,'Diagnosis 5','Treatment 5','None','120/80','95',60,165,'2025-02-06','2025-03-06','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(6,6,'Diagnosis 6','Treatment 6','None','120/80','95',61,166,'2025-02-07','2025-03-07','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(7,7,'Diagnosis 7','Treatment 7','None','120/80','95',62,167,'2025-02-08','2025-03-08','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(8,8,'Diagnosis 8','Treatment 8','None','120/80','95',63,168,'2025-02-09','2025-03-09','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(9,9,'Diagnosis 9','Treatment 9','None','120/80','95',64,169,'2025-02-10','2025-03-10','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(10,10,'Diagnosis 10','Treatment 10','None','120/80','95',65,170,'2025-02-11','2025-03-11','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(11,11,'Diagnosis 11','Treatment 11','None','120/80','95',66,171,'2025-02-12','2025-03-12','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(12,12,'Diagnosis 12','Treatment 12','None','120/80','95',67,172,'2025-02-13','2025-03-13','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(13,13,'Diagnosis 13','Treatment 13','None','120/80','95',68,173,'2025-02-14','2025-03-14','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(14,14,'Diagnosis 14','Treatment 14','None','120/80','95',69,174,'2025-02-15','2025-03-15','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(15,15,'Diagnosis 15','Treatment 15','None','120/80','95',70,175,'2025-02-16','2025-03-16','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(16,16,'Diagnosis 16','Treatment 16','None','120/80','95',71,176,'2025-02-17','2025-03-17','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(17,17,'Diagnosis 17','Treatment 17','None','120/80','95',72,177,'2025-02-18','2025-03-18','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(18,18,'Diagnosis 18','Treatment 18','None','120/80','95',73,178,'2025-02-19','2025-03-19','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(19,19,'Diagnosis 19','Treatment 19','None','120/80','95',74,179,'2025-02-20','2025-03-20','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(20,20,'Diagnosis 20','Treatment 20','None','120/80','95',55,160,'2025-02-21','2025-03-21','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(21,21,'Diagnosis 21','Treatment 21','None','120/80','95',56,161,'2025-02-22','2025-03-22','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(22,22,'Diagnosis 22','Treatment 22','None','120/80','95',57,162,'2025-02-23','2025-03-23','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(23,23,'Diagnosis 23','Treatment 23','None','120/80','95',58,163,'2025-02-24','2025-03-24','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(24,24,'Diagnosis 24','Treatment 24','None','120/80','95',59,164,'2025-02-25','2025-03-25','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(25,25,'Diagnosis 25','Treatment 25','None','120/80','95',60,165,'2025-02-26','2025-03-26','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(26,26,'Diagnosis 26','Treatment 26','None','120/80','95',61,166,'2025-02-27','2025-03-27','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(27,27,'Diagnosis 27','Treatment 27','None','120/80','95',62,167,'2025-02-28','2025-03-28','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(28,28,'Diagnosis 28','Treatment 28','None','120/80','95',63,168,'2025-02-01','2025-03-01','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(29,29,'Diagnosis 29','Treatment 29','None','120/80','95',64,169,'2025-02-02','2025-03-02','Stable');
INSERT INTO medical_records(patient_id,doctor_id,diagnosis,treatment,allergies,blood_pressure,sugar_level,weight,height,visit_date,follow_up_date,remarks) VALUES(30,30,'Diagnosis 30','Treatment 30','None','120/80','95',65,170,'2025-02-03','2025-03-03','Stable');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine1','Mfg1','Tablet',51,101,'2027-12-31','B0001','Supplier1','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine2','Mfg2','Tablet',52,102,'2027-12-31','B0002','Supplier2','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine3','Mfg3','Tablet',53,103,'2027-12-31','B0003','Supplier3','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine4','Mfg4','Tablet',54,104,'2027-12-31','B0004','Supplier4','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine5','Mfg5','Tablet',55,105,'2027-12-31','B0005','Supplier5','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine6','Mfg6','Tablet',56,106,'2027-12-31','B0006','Supplier6','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine7','Mfg7','Tablet',57,107,'2027-12-31','B0007','Supplier7','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine8','Mfg8','Tablet',58,108,'2027-12-31','B0008','Supplier8','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine9','Mfg9','Tablet',59,109,'2027-12-31','B0009','Supplier9','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine10','Mfg10','Tablet',60,110,'2027-12-31','B0010','Supplier10','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine11','Mfg11','Tablet',61,111,'2027-12-31','B0011','Supplier11','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine12','Mfg12','Tablet',62,112,'2027-12-31','B0012','Supplier12','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine13','Mfg13','Tablet',63,113,'2027-12-31','B0013','Supplier13','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine14','Mfg14','Tablet',64,114,'2027-12-31','B0014','Supplier14','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine15','Mfg15','Tablet',65,115,'2027-12-31','B0015','Supplier15','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine16','Mfg16','Tablet',66,116,'2027-12-31','B0016','Supplier16','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine17','Mfg17','Tablet',67,117,'2027-12-31','B0017','Supplier17','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine18','Mfg18','Tablet',68,118,'2027-12-31','B0018','Supplier18','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine19','Mfg19','Tablet',69,119,'2027-12-31','B0019','Supplier19','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine20','Mfg20','Tablet',70,120,'2027-12-31','B0020','Supplier20','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine21','Mfg21','Tablet',71,121,'2027-12-31','B0021','Supplier21','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine22','Mfg22','Tablet',72,122,'2027-12-31','B0022','Supplier22','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine23','Mfg23','Tablet',73,123,'2027-12-31','B0023','Supplier23','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine24','Mfg24','Tablet',74,124,'2027-12-31','B0024','Supplier24','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine25','Mfg25','Tablet',75,125,'2027-12-31','B0025','Supplier25','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine26','Mfg26','Tablet',76,126,'2027-12-31','B0026','Supplier26','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine27','Mfg27','Tablet',77,127,'2027-12-31','B0027','Supplier27','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine28','Mfg28','Tablet',78,128,'2027-12-31','B0028','Supplier28','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine29','Mfg29','Tablet',79,129,'2027-12-31','B0029','Supplier29','25C');
INSERT INTO medicines(medicine_name,manufacturer,category,price,stock_quantity,expiry_date,batch_number,supplier,storage_temperature) VALUES('Medicine30','Mfg30','Tablet',80,130,'2027-12-31','B0030','Supplier30','25C');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(1,1,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(2,2,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(3,3,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(4,4,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(5,5,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(6,6,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(7,7,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(8,8,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(9,9,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(10,10,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(11,11,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(12,12,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(13,13,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(14,14,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(15,15,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(16,16,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(17,17,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(18,18,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(19,19,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(20,20,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(21,21,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(22,22,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(23,23,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(24,24,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(25,25,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(26,26,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(27,27,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(28,28,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(29,29,'1-0-1','5 Days',10,'After Food');
INSERT INTO prescriptions(record_id,medicine_id,dosage,duration,quantity,instructions) VALUES(30,30,'1-0-1','5 Days',10,'After Food');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(1,1,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-02');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(2,2,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-03');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(3,3,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-04');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(4,4,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-05');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(5,5,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-06');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(6,6,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-07');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(7,7,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-08');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(8,8,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-09');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(9,9,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-10');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(10,10,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-11');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(11,11,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-12');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(12,12,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-13');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(13,13,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-14');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(14,14,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-15');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(15,15,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-16');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(16,16,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-17');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(17,17,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-18');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(18,18,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-19');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(19,19,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-20');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(20,20,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-21');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(21,21,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-22');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(22,22,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-23');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(23,23,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-24');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(24,24,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-25');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(25,25,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-26');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(26,26,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-27');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(27,27,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-28');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(28,28,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-01');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(29,29,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-02');
INSERT INTO billing(patient_id,appointment_id,consultation_fee,medicine_cost,lab_charges,room_charges,discount,tax,total_amount,payment_method,payment_status,billing_date) VALUES(30,30,500,100,200,300,50,75,1125,'UPI','Paid','2025-02-03');


Doctor ID, Doctor Name, Specialization, Department Name, Consultation Fee, and Salary.


use hospital_db;
The view should include the Patient ID, Patient Name, Gender, Date of Birth, Blood Group, City, State, and Insurance Provider.

use hospital_db;

create view patient_view
as select patient_id as 'Patient ID',concat(first_name,' ',last_name) as 'Patient Name',dob as 'Date of Birth',blood_group as 'Blood Group',city as City ,state as State,insurance_provider as 'Insurance Provider'
     from patients;
select * from patient_view;


Create a view that displays all medicines whose available stock quantity is less than 100. Display all the columns of the medicine.

use hospital_db;
create view medicine_view as
select * from  medicines
where stock_quantity<100;

select * from medicine_view;


Create a view that displays only the appointments that have been completed. Include all appointment details in the view.


select * from appointments;
create view appointment_view as
select * from appointments
where appointment_status='Completed';

select * from appointment_view;

Create a view that displays the details of doctors who have more than 10 years of experience. Include all doctor-related information.

create view doctor_experience_morethan10 as
select * from doctors
where experience>10;

select * from doctor_experience_morethan10;

Create a view that displays appointment details along with the patient name, doctor name, department name, appointment date, appointment time, consultation type, and appointment status.

create view appo_pat_doc_dept_view as
select concat(p.first_name,' ',p.last_name) as 'patient name',concat(d.first_name,'  ',d.last_name) as 'doctor name',
dept.department_name as 'department name',a.appointment_date as 'appointment
date',a.appointment_time as 'appointment
time',a.consultation_type as 'consultation type',a.appointment_status as 'appointment status'
from patients p inner join appointments a
on  p.patient_id=a.patient_id inner join doctors d 
on d.doctor_id=a.doctor_id inner join departments dept 
on dept.department_id=d.department_id;

select * from appo_pat_doc_dept_view ;	
 Create a view that displays the complete medical history of every patient. 
 The view should display the Patient Name, Doctor Name, Diagnosis, Treatment, Visit Date, Follow-up Date, and Doctor remarks
 
 
 create view pat_mr_doctor as
 select concat(p.first_name,'  ',p.last_name ) as 'patient name',concat(d.first_name,'  ',d.last_name ) as 'doctor name',mr.diagnosis,mr.treatment,mr.visit_date,mr.follow_up_date,mr.
 remarks as 'doctors remarks'
 from patients p inner join medical_records mr
 on p.patient_id=mr.patient_id inner join doctors d
 on d.doctor_id=mr.doctor_id;


select * from  pat_mr_doctor;

Create a view that displays the billing details of every patient. 
The view should display the Patient Name, Doctor Name, Consultation Fee, Medicine Cost, Lab Charges, Room Charges, Total Amount, Payment Method, and Payment Status.

create view pn_dn_bill as
select concat(p.first_name,' ',p.last_name) as 'patient name',concat(d.first_name,' ',d.last_name) as 'doctor name',d.consultation_fee,b.medicine_cost,b.lab_charges,b.room_charges,
b.total_amount,b.payment_method,b.payment_status
from billing b inner join patients p
on b.patient_id=p.patient_id inner join appointments a
on p.patient_id=a.patient_id inner join doctors d
on a.doctor_id=d.doctor_id
;

select * from departments;




Create a view that displays prescription details for every patient.
 The view should include the Patient Name, Doctor Name, Medicine Name, Dosage, Duration, Quantity, and Instructions.
select * from doctors;

select concat(d.first_name,' ',d.last_name) as 'doctors name',dep.department_name,dep.hod_name,d.specialization,d.consultation_fee,count(a.appointment_id)
from doctors d inner join appointments a
on d.doctor_id=a.doctor_id inner join departments dep
on dep.department_id=d.department_id
group by d.doctor_id;

Create a view that generates a complete
 hospital report containing the Patient Name, Doctor Name, Department Name, Diagnosis, 
 Prescribed Medicine, Total Bill Amount, and Payment Status.


select  concat(p.first_name,' ',p.last_name) as 'Patient Name',concat(d.first_name,' ',d.last_name) as 'Doctor name',dep.department_name,mr.diagnosis,med.medicine_name,
b.total_amount,b.payment_status
from billing b inner join appointments a
on b.appointment_id=a.appointment_id inner join  doctors d
on a.doctor_id=d.doctor_id inner join departments dep
on d.department_id=dep.department_id inner  join  patients p
on a.patient_id=p.patient_id inner join medical_records mr
on p.patient_id=mr.patient_id inner join prescriptions pr
on pr.record_id=mr.record_id inner join medicines med
on med.medicine_id=pr.medicine_id;

select * from doctors;





select * from billing;

create database triggers;
use triggers;


create table employee(emp_id int primary key auto_increment,ename varchar(10),ejoining_date date,esalary double);


Delimiter $$
	create trigger before_insert_sal
	before insert on employeee
	for each row
	begin
	if new.esalary<0 then
	signal sqlstate '45000'
	set message_text='salary should not be lesser tahn zero';
	end if;
	end $$
    
    insert into employee(ename,ejoining_date,esalary)values('vignesh','2000-02-21',-21000);
    
    
delimiter %%
create table employee_after_insert_track(log_id int primary key auto_increment,emp_id int ,message varchar(50),insert_time datetime );
create trigger afer_insert_trigger
after insert on employee
for each row 
begin
insert into employee_after_insert_track(emp_id,message,insert_time)values
(new.emp_id,concat('welcome to the applicarion'),new.ename,now());

end %%
delimiter ;

select * from employee_after_insert_track;

insert into 
drop table employee_after_insert_track;

    insert into employee(ename,ejoining_date,esalary)values('vignesh','2000-02-21',21000);

 select * from employee_after_insert_track;



delimiter $$
create trigger salary_update_before
before update on employee
for each row 
begin 
		if old.esalary>new.esalary  then 
        signal sqlstate '45000'
        set message_text='new salary should not be lesser  than old salary';
        end if ;
        end $$
        delimiter ;
        

drop trigger salary_update_before;




delimiter $$
create trigger salary_update_before
before update on employee
for each row 
begin 
		if old.esalary>new.esalary  then 
        signal sqlstate '45000'
        set message_text='new salary should not be lesser  than old salary';
        end if ;
        
        if new.ejoining_date=old.ejoining_date
        then 
        signal sqlstate '45000'
        set message_text='old and new joining date is same';
        end if;
        end $$
        delimiter ;
        
        select * from employee;
        
        use triggers;
        insert into employee (ename,ejoining_date,esalary)values('vignesh','2000-01-01',75000);


drop table employee;
drop trigger salary_update_before;


desc employee;

DROP TABLE IF EXISTS employee;

CREATE TABLE employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    ename VARCHAR(10),
    ejoining_date DATE,
    esalary DOUBLE
);

DELIMITER $$
CREATE TRIGGER salary_update_before
BEFORE UPDATE ON employee
FOR EACH ROW
BEGIN
    IF OLD.esalary > NEW.esalary THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New salary should not be lesser than old salary';
    END IF;

    IF NEW.ejoining_date = OLD.ejoining_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Old and new joining date is same';
    END IF;
END$$
DELIMITER ;

INSERT INTO employee (ename, ejoining_date, esalary)
VALUES ('vignesh', '2000-01-01', 75000);

select * from employee;
update employee,ejoining_date
set esalary=74000 and ejoining_date='1990-01-01'
where emp_id=1;


create table teacher(tid int primary key auto_increment,tname varchar(10) ,tsalary int ,tjoining_date date);

delimiter %%
create trigger before_insert_tsalary
before insert on teacher
for each row
begin
		if new.tsalary<0 then 
        signal sqlstate '45000'
        set message_text='salary cant be lesser than zero';
        end if;
        end %%
delimiter ;
desc employee;

insert into teacher(tname,tsalary,tjoining_date)values('Tanzeem',750000,'2020-01-01');
insert into teacher(tname,tsalary,tjoining_date)values('Tanzeem',-750000,'2020-01-01');
==================================================================================================================================
after insert===============
use triggers;
create table audit_logs(aid int primary key auto_increment ,emp_id int,ename varchar(20),esalary int,ejoining_date datetime,message varchar(100
),timeduration datetime);
delimiter %%
create trigger after_insert_trigger
after insert on employee
for each row
begin
insert into audit_logs(emp_id,ename,esalary,ejoining_date,message,timeduration)values
(new.emp_id,new.ename,new.esalary,new.ejoining_date,concat(new.ename,'welcome to the application'),now());
end %%
delimiter ;
INSERT INTO employee (ename, ejoining_date, esalary)
VALUES ('vino', '2000-01-03', 78000);
select * from audit_logs;



=============================================================================================================================================================================
/////after update///


create table employee_update_logs(eul_id int primary key auto_increment,emp_id int ,old_salary double,new_salary double,
old_joining_date date,new_joining_date date,updation_time datetime );
desc employee;
delimiter $$
create trigger audit_log_update
after update on employee
for each row
begin
insert into employee_update_logs(emp_id,old_salary,new_salary,old_joining_date,new_joining_date,updation_time)
values(old.emp_id,old.esalary,new.esalary,old.ejoining_date,new.ejoining_date,now());
end $$
delimiter ;

INSERT INTO employee (ename, ejoining_date, esalary)
VALUES ('veera', '2000-01-01', 95000);

update employee
set esalary=100000,ejoining_date='2005-01-01' 
where emp_id=2;

===================================================================================================================================

///before delete

select * from employee;
select * from employee_update_logs;

	delimiter %%
	create trigger before_delete
	before delete on employee
	for each row 
	begin
	if old.emp_id=1 then 
	signal sqlstate '45000'
	set message_text='1st employee is consider owner and not get deleted';
	end if;
	end %%
	delimiter ;
    
    delete from employee
    where emp_id=1;
    
    drop trigger before_delete;


after delete=======================
use triggers;
create table after_delete_logs
(did int primary key auto_increment ,emp_id int ,ename varchar(10),esalary int,ejoining date);

delimiter %%
create trigger after_delete
after delete on employee
for each row
begin
insert into after_delete_logs(emp_id,ename,esalary,ejoining)values
(old.emp_id,old.ename,old.esalary,old.ejoining_date);
end %%
delimiter ;
drop table after_delete_logs;
delete from employee
where emp_id=2;
select * from after_delete_logs;


===================================
create database triggerassignment;

use triggerassignment;

create table customer
(
    customer_id int primary key auto_increment,
    customer_name varchar(50) not null,
    age int not null,
    gender enum('Male','Female','Other'),
    mobile_no varchar(10) not null,
    pan_no varchar(10) not null unique,
    aadhaar_no varchar(12) not null unique,
    account_type enum('Savings','Current') default 'Savings',
    balance decimal(12,2) not null,
    opening_date date default (current_date)
);


-- before insert 
delimiter $$
create trigger initial_inserted_customer
before insert on customer
for each row
begin
    if new.balance < 1000 or new.balance is null then
    signal sqlstate '45000'
    set message_text = 'Minimum balance should be 1000 or more than 1000';
    end if;
	
    if New.age < 18 or new.age is null  then
    signal sqlstate '45000'
    set message_text = 'Customer age should be atleast 18';
    end if;
    
    if New.pan_no is null then
    signal sqlstate '45000'
    set message_text = 'Customer should have pancard or enter the pancard number';
    end if;
    
    if length(new.mobile_no) < 10 or new.mobile_no is null or length(new.mobile_no) > 10  then
    signal sqlstate '45000'
    set message_text = 'Mobile Number is invalid';
    end if;
    
    if length(new.aadhaar_no) < 12 or new.mobile_no is null or length(new.aadhaar_no) > 12  then
    signal sqlstate '45000'
    set message_text = 'Mobile Number is invalid';
    end if;
    
end $$
delimiter ;

drop trigger initial_inserted_customer;


-- after insert

create table customer_log
(
    log_id int primary key auto_increment,
    customer_id int,
    customer_name varchar(50),
    action_performed varchar(100),
    action_time datetime
);

delimiter $$
create trigger initial_insertion_log
after insert on customer
for each row
begin 
	insert into  customer_log(customer_id,
    customer_name,
    action_performed,
    action_time) values (new.customer_id,new.customer_name,'Customer id created',now());
 end$$
 delimiter ;
 
 drop trigger initial_insertion_log;
 
 
 
 -- cross check for before insert and after insert 
 select * from customer; truncate table customer;
 select * from customer_log; truncate table customer_log;
 
 insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Rahul Sharma',25,'Male','9876543210','ABCDE1234F','123456789012','Savings',5000);

-- age
insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values                             
('Rohit',16,'Male','9876543210','PQRSX5678K','234567890123','Savings',3000);

-- balance
insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Priya',23,'Female','9876543211','LMNOP1234Q','345678901234','Savings',800);

--  pan
insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Anjali',24,'Female','9123456789',null,'456789012345','Savings',2000);

-- mobile number < 10
insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Kiran',30,'Male','98765432','ZXCVB6789L','567890123456','Current',4000);


-- mobile number > 10
insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Meena',27,'Female','987654321012','QWERT1234Y','678901234567','Savings',6000);

insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Arun',29,'Male','9988776655','ABCDE1234F','789012345678','Savings',5000);

insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Suresh',40,'Male','9871234567','ASDFG9876H','123456789012','Current',8000);

insert into customer
(customer_name,age,gender,mobile_no,pan_no,aadhaar_no,account_type,balance)
values
('Sneha',31,'Female','9012345678','TYUIO5678R','901234567890','Savings',15000);

select * from customer; select * from customer_log;



-- update 
-- before update

delimiter $$
create trigger before_customer_data_update
before update on customer
for each row
begin 
	if new.age is not null  then
		if 18 > new.age then
			signal sqlstate '45000'
			set message_text = 'Customer age should be atleast 18';
		end if;
	end if;
    
    if new.mobile_no is not null then
		if length(new.mobile_no) < 10 and length(new.mobile_no) > 10  then
			signal sqlstate '45000'
			set message_text = 'Mobile number is same';
		else if length(new.mobile_no) = 10 and new.mobile_no != old.mobile_no then
			set new.mobile_no = new.mobile_no;
            end if;
		end if;
	end if;
    
    if new.pan_no is not null then
		if old.pan_no != new.pan_no then
			signal sqlstate '45000'
			set message_text = 'Pan Card cannot be updated again';
		end if;
	end if;
    
    if new.aadhaar_no is not null then
		if old.aadhaar_no != new.aadhaar_no then
			signal sqlstate '45000'
			set message_text = 'Aadhaar number cannot be updated again';
		end if;
	end if;
    
    if new.balance is not null then 
		if new.balance < 0 then
			set new.balance = new.balance+(-50);
		end if;
	end if;

end $$
delimiter ;

drop trigger before_customer_data_update;


create table customer_update_audit
(
    audit_id int primary key auto_increment,
    customer_id int,
    customer_name varchar(50),
    old_age int,
    new_age int,
    old_mobile_no varchar(10),
    new_mobile_no varchar(10),
	old_balance decimal(12,2),
    new_balance decimal(12,2),
    updated_on datetime 
);

-- after update

delimiter $$
create trigger after_update_log
after update on customer
for each row
begin 
	insert into customer_update_audit(customer_id ,
    customer_name,
    old_age ,
    new_age ,
    old_mobile_no ,
    new_mobile_no ,
	old_balance ,
    new_balance ,
    updated_on) 
    values ( old.customer_id,
					old.customer_name,
					old.age,
                    new.age,
                    old.mobile_no,
                    new.mobile_no,
                    old.balance,
                    new.balance,
                    now());
end $$
delimiter ;

update customer
set age = 17
where customer_id = 1;

update customer
set mobile_no = '9998887776'
where customer_id = 2;

update customer
set balance = balance - 1
where customer_id = 8;

update customer
set age = 29,
    balance = balance + 8500
where customer_id = 8;

update customer
set mobile_no = '8887776665',
    balance = balance + 14000
where customer_id = 9;

update customer
set pan_no = 'AAAAA1111A'
where customer_id = 1;

update customer
set aadhaar_no = '999988887777'
where customer_id = 2;

update customer
set pan_no = 'BBBBB2222B',
    aadhaar_no = '888877776666'
where customer_id = 8;

update customer
set mobile_no = '9876501234'
where customer_id = 1;

update customer
set age = 35,
    pan_no = 'CCCCC3333C'
where customer_id = 8;



select * from customer;
select * from customer_update_audit;



-- delete
-- before and after delete here it is same

-- Error Code: 1363. There is no NEW row in on DELETE trigger
-- delimiter $$
-- create trigger deleted_emp
-- after delete on employee
-- for each row
-- begin
-- 	if old.customer_id = new.customer_id then
-- 		signal sqlstate '45000'
-- 			set message_text = 'Aadhaar number cannot be updated again';
-- 		end if;
-- end $$
-- delimiter ;


delimiter $$
create trigger deleted_emp_audit
after delete on customer
for each row
begin
	
	insert into deleted_customer values (old.customer_id ,
    old.customer_name,
    old.age ,
    old.gender ,
    old.mobile_no,
    old.pan_no ,
    old.aadhaar_no ,
    old.account_type ,
    old.balance ,
    old.opening_date,
    now());
    
end $$
delimiter ;

create table deleted_customer
(
    customer_id int,
    customer_name varchar(50),
    age int,
    gender enum('Male','Female','Other'),
    mobile_no varchar(10),
    pan_no varchar(10),
    aadhaar_no varchar(12),
    account_type enum('Savings','Current'),
    balance decimal(12,2),
    opening_date date,
    deleted_on datetime
);

delete from customer
where customer_id = 8;

select * from customer;
select * from deleted_customer;
use hospital_db;


delimiter %%
create procedure female_doctor()

begin
select * from doctors
where gender='female';
end %%
delimiter ;

call hospital_db.female_doctor();


delimiter %%
create procedure doctor_dep()
begin
select doctor_id,concat(first_name,' ',last_name),d.department_id,dept.department_name
from doctors d inner join departments dept
on d.department_id=dept.department_id
where dept.department_name='neurology';
end %%
delimiter ;

drop procedure doctor_dep;
call hospital_db.doctor_dep();

delimiter %%
create procedure search_dep(in dept_type varchar(50))
begin
select doctor_id,concat(first_name,' ',last_name),d.department_id,dept.department_name
from doctors d inner join departments dept
on d.department_id=dept.department_id
where dept.department_name=dept_type;
end %%
delimiter ;

call hospital_db.search_dep('ent');
call hospital_db.search_dep('cardiology');
use hospital_db;
delimiter %%
create procedure count_doctor_pro(out count_doctors  int )
begin
		select count(*) into count_doctors
        from doctors;
	end %%
    delimiter ;
    drop  procedure count_doctor_pro;
    
    
    call hospital_db.count_doctor_pro(@result_of_count);
    select @result_of_count;
    
    
    use hospital_db;
delimiter %%
create procedure count_doctor_product(in a int,in b int ,in c int ,out mul_3  int )
begin
		
		select a*b*c into mul_3;
	end %%
    delimiter ;
    drop procedure count_doctor_pro;
    
    call hospital_db.count_doctor_product(10,20,30,@product);
    select @product;
    
    
    
    delimiter %%
create procedure count_doctor_square(in square_val int  ,out square_one  int )
begin
		
		select square_val*square_val into square_one;
	end %%
    delimiter ;
    drop procedure count_doctor_pro;
    
    call hospital_db.count_doctor_square(10,@square_out);
    select @square_out as square;
    




   delimiter %%
create procedure count_doctor_square_mul(in square_val1 int  ,square_val2 int, square_val3  int,
out square_one  int , square_two int , square_three int,square_one int)
begin
		
		select square_val1*square_val1 into square_one,
        square_val1*square_val1;
	end %%
    delimiter ;
    drop procedure count_doctor_pro;
    
    call hospital_db.count_doctor_square(10,@square_out);
    select @square_out as square;




use hospital_db;
 delimiter %%
create procedure pro_1(in patient_names varchar(50))

begin

		select concat(d.first_name,d.last_name) as doctors_name,dep.department_name,ap.appointment_time,ap.appointment_date,concat(pa.first_name,pa.last_name)
        from doctors d inner join departments dep
        on d.department_id=dep.department_id inner join appointments ap
        on d.doctor_id=ap.doctor_id inner join patients pa
        on ap.patient_id=pa.patient_id
        where pa.first_name=patient_names;
        
        end %%
	
    delimiter ;
    call hospital_db.pro_1('patient1');
    
=========================================================================================    
    delimiter %%
    create procedure pro_2(in patient_id varchar(50))
    begin
       select concat(d.first_name,d.last_name) as  doctor_name,dep.department_name,b.total_amount ,b.payment_status
       from doctors d inner join  departments dep
       on d.department_id=dep.department_id inner join appointments a
       on d.doctor_id=a.doctor_id inner join billing b
       on a.appointment_id=b.appointment_id
       where b.patient_id=patient_id;
       end %%
delimiter ;
call hospital_db.pro_2(1);
===============================================================================================
 delimiter %%
    create procedure pro_3(in patient_id varchar(50))
    begin
       select concat(p.first_name,p.last_name) as  patient_name,p.patient_id,pr.*
       from patients p inner join  medical_records mr
       on p.patient_id=mr.patient_id inner join prescriptions pr
       on mr.record_id=pr.record_id
       where p.patient_id=patient_id;
       end  %%
delimiter ;
call hospital_db.pro_3(6);
=====================================================================================
 delimiter %%
    create procedure pro_4(in doctor_id varchar(50))
    begin
       select concat(d.first_name,d.last_name) as doctor_name,mr.*
       from doctors d inner join medical_records mr
       on d.doctor_id=mr.doctor_id
       where d.doctor_id = doctor_id;
       
       end %%
delimiter ;
call hospital_db.pro_4(1);
========================================================================

delimiter %%
    create procedure pro_5(in status_ap varchar(50))
    begin
       select concat(p.first_name,' ',p.last_name) as patient_name,concat(d.first_name,' ',d.last_name) as doctors_name,a.*
       from patients p inner join appointments a 
       on p.patient_id=a.patient_id inner join doctors d
       on a.doctor_id=d.doctor_id
       where a.appointment_status=status_ap;
       
       end %%
delimiter ;

call hospital_db.pro_5('completed');
======================================================================












use s_operator;

create table pk(dept_id  int primary key ,dep_name varchar(40));




create table fk(fk_id int primary key,student_name varchar(50),dept_id int ,foreign key (dept_id) references pk(dept_id));




desc fk;




use hospital_db;

select d.*
from doctors d
where d.salary>(select abg(sal)
from doctors d1
group by)




use hospital_db;

create index index1
on doctors(doctor_id);

select * from doctors where doctor_id<10;
show indexes from doctors;

create database test;

use test;
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary INT,
    age INT,
    department_id INT,
    manager_id INT,
    joining_date DATE
);
INSERT INTO Employee VALUES
(101,'John',80000,30,1,105,'2022-01-10'),
(102,'Alice',60000,28,2,106,'2021-05-15'),
(103,'Bob',45000,24,2,106,'2023-03-20'),
(104,'David',70000,32,3,107,'2020-08-12'),
(105,'Michael',95000,40,1,NULL,'2018-06-25'),
(106,'Sarah',85000,38,2,NULL,'2019-04-18'),
(107,'James',90000,42,3,NULL,'2017-11-01'),
(108,'Emma',55000,27,1,105,'2024-01-05'),
(109,'Sophia',65000,29,4,110,'2022-09-09'),
(110,'William',100000,45,4,NULL,'2016-02-14'),
(111,'Chris',48000,26,NULL,NULL,'2025-02-10'),
(112,'Olivia',60000,31,2,106,'2023-07-22'),
(113,'Daniel',80000,35,3,107,'2021-12-01'),
(114,'Mia',70000,30,4,110,'2020-10-10'),
(115,'Ethan',50000,25,1,105,'2024-04-15');
CREATE TABLE Department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50)
);

INSERT INTO Department VALUES
(1,'IT'),
(2,'HR'),
(3,'Finance'),
(4,'Sales'),
(5,'Marketing');
Display all employee names.
Display employee names whose salary is greater than 50,000.
Display employees whose age is between 25 and 30.
Find the total number of employees.
Display employees sorted by salary in descending order.


select emp_name  as employee_name,salary
from employee;
select emp_name
from employee
where salary   >50000;

select * from employee
where age between 25 and 30;

select count(*)
from employee;

select * from employee
order by salary desc;
Find the highest salary.
Find the second highest salary.
Find the third highest salary.
Find the average salary in each department.
Display departments having more than 5 employees.

select max(salary) as highest_salary
from employee;

select salary as max_salary
from employee
order by salary desc
limit 1 offset 1;

select salary
from employee e
where 3=(select distinct count(*)
from employee e1
where e1.salary>=e.salary);

select department_id,avg(salary) as average_salary
from employee
group by department_id;

select department_id,count(emp_name)
from employee
group by department_id
having count(*)>5;

Display employee name and department name.
Display employees who dot belong to any department.
Display departments that have no employees.
Display employee name and manager name (Self Join).
Display employees earning more than their manager.



select d.department_name,e.emp_name
from department d inner join employee e
on d.department_id=e.department_id
group by d.department_id
having count(*) is null;

select e.emp_name as employee_name,m.emp_name as manager_name
from employee e join employee m
on e.emp_id=m.emp_id;

Find employees earning more than the average salary.
Find employees working in the same department as 'John'.
Find employees with the maximum salary in each department.
Find employees who are not managers.
Find departments where the average salary is greater than 60,000.

select * from employee
where salary>(select avg(salary)
from employee);

select * from 
employee
where department_id=(select department_id
from employee
where emp_name='john');

select *
from employee
where salary in(select max(salary)
from employee
group by department_id);

select *
from employee
where manager_id is not null;

select * 
from employee
where manager_id is null;

select department_id,avg(salary)
from employee
group by department_id
having avg(salary)>60000;

select *,rank()over(order by salary desc )as ranks
from employee;


select * ,dense_rank()over(order by salary desc)
as ranks
from employee;

select *
from (select * ,dense_rank()over(partition by department_id order by salary desc)as ranks
from employee)as t
where ranks <=3;
create database j2ee_student;

use j2ee_student;
drop table student;

create table student(id int primary key auto_increment,name varchar(30) not null, phoneno varchar(20) unique not null ,email varchar(20) unique not null );


select * from student;
use ddl;



create table music(id int primary key auto_increment,name varchar(20) not null,year date not null);


create unique index date_indexx
on music(year);



show index from music;


drop index fullind on music;

drop index date_indexx on music;

create index comp_ind
on music(name,year);

drop index comp_ind on music;

create fulltext index fullind
on music(name);

desc music;

create spatial index  spatialind on music(name);


create functional index


show create table from music;

create index functional_index
on music((lower(name)));

show index from music;
CREATE TABLE emp (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    deptno INT,
    salary DECIMAL(10,2)
);

INSERT INTO emp VALUES
(101, 'SMITH', 10, 25000),
(102, 'ALLEN', 20, 30000),
(103, 'JONES', 10, 35000),
(104, 'SCOTT', 30, 40000),
(105, 'KING', 20, 45000);
delimiter &&
create procedure display_emo()
begin 
select * 
from emp;
end &&
delimiter ;


call display_emo();



delimiter &&
create procedure display_emp_dip(in deeptno int)
begin
select * from emp
where deptno=deeptno;
end &&
delimiter ;

call display_emp_dip(20);



delimiter $$
create procedure highest_sal(out max_salar decimal(10,2) )
begin
select max(salary) into max_salar from emp;
end $$ 
delimiter ;
drop procedure highest_sal;
call highest_sal(@max_salary);
select @max_salary;
select * from emp;
desc emp;
delimiter %%
create procedure inoutpara(in em_id int ,out salar decimal(10,2))
begin 
select salary into salar 
from emp
where emp_id=em_id;
end %%
delimiter ;

drop procedure inoutpara;
call inoutpara(101,@salary);


select @salary;

delimiter %%
create procedure inoutpr(inout salar int )
begin
select salary+salar into salar
from emp;
end %%
delimiter ;


CREATE TABLE emp2 (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    deptno INT,
    salary DECIMAL(10,2)
);

delimiter %%
create trigger before_insert before insert
on emp2
for each row
begin if new.salary <1000 then set new.salary=1000; end if;
end %%
delimiter ;

insert into emp2 values(01,'vignesh',2,9999);

insert into emp2 values(09,'vigsh',21,4000);
drop trigger before_insert;
delimiter %%
create trigger beforeins
before insert on emp2
for each row 
begin
if new.salary <500 then signal sqlstate '45000'
set message_text='paapa salary is low';
end if;
end %%
delimiter ;



reate table emp2_insert_log(eul_id int primary key auto_increment,new_salary int ,date_time date );

delimiter %%
create trigger after_insert
after insert on emp2
for each row 
begin


insert into emp2_insert_log(new_salary,date_time)value(new.salary,now());
end %%
delimiter ;
select * from emp2_insert_log;
inser

call inoutpr(25000);

delimiter %%
create procedure emp2details 
()
begin
select * from emp2;
end %%
delimiter ;


call emp2details();


delimiter %%
create trigger beforeupdate before update on emp2
for each row 
begin 
if new.salary<old.salary then signal sqlstate '45000' set message_text='paapa salary is lees than the previous salary
';
end if;
end %%
delimiter ;

select * from emp2;

update  emp2
set salary=100
where emp_id=1;




create table update_log 
(eul_id int primary key auto_increment,oldsalary int ,newsalary int ,time datetime);


delimiter %%
create trigger after_upadte
after update on emp2
for each row 
begin
insert into update_log(oldsalary,newsalary,time)values(old.salary,new.salary,now());
end %%
delimiter ;


update emp2
set salary =20000
where emp_id=1;

select * from update_log;


delimiter %%
create trigger before_delete
before delete on emp2
for each row
begin
if old.salary>2000 then signal sqlstate '45000' set message_text='salary cant be deleted';
end if;
end %%
delimiter ;

select * from emp2;

set sql_safe_updates=0;
delete from emp2
where salary=20000;

set sql_safe_updates=1;



create view retrieve
as 
select * from emp2;

select * from retrieve;



select ename,case deptno
when 2 then 'good'
when 21 then 'very good'
else 'not good'
end as nk
from emp2
where deptno=2;

CREATE TABLE emp3 (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    job VARCHAR(30),
    salary DECIMAL(10,2),
    deptno INT
);

drop table emp3;

INSERT INTO emp3 VALUES
(101, 'SMITH', 'CLERK', 25000, 10),
(102, 'ALLEN', 'SALESMAN', 30000, 20),
(103, 'JONES', 'MANAGER', 40000, 10),
(104, 'SCOTT', 'ANALYST', 35000, 30),
(105, 'KING', 'MANAGER', 50000, 20);


create table cpyolnystructure like emp3;


desc cpyolnystructure;

create table structureplusdata as
select * from emp3;




desc structureplusdata;


create table emp4
like emp3;

insert into emp4
select * from emp3;

select * from emp4;





use case1;


CREATE TABLE emp3 (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    job VARCHAR(30),
    salary DECIMAL(10,2),
    deptno INT
);

INSERT INTO emp3 VALUES
(101, 'SMITH', 'CLERK', 25000, 10),
(102, 'ALLEN', 'SALESMAN', 30000, 20),
(103, 'JONES', 'MANAGER', 40000, 10),
(104, 'SCOTT', 'ANALYST', 35000, 30),
(105, 'KING', 'MANAGER', 50000, 20);


create table copystructure like emp3;

create table datastructure as select * from emp3;

create table datastructureconstraint like emp3;
insert into datastructureconstraint
select * from emp3;


create table rowsonly as select * from emp3  where salary >10000;


create table columnonly as select emp_id,ename from emp3;



create table columnroe as select emp_id,ename from emp3 where salary>20000;

create table usingselect as select * from emp3 where salary<0;


select *,sum(salary)over()
from emp3;

select *,sum(salary)over(order by salary rows between current row and unbounded following)
from emp3;




CREATE TABLE emplo (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(50),
    job VARCHAR(30),
    salary DECIMAL(10,2),
    deptno INT,
    hire_date DATE
);

INSERT INTO emplo VALUES
(101, 'SMITH',  'CLERK',     25000, 10, '2020-01-10'),
(102, 'ALLEN',  'SALESMAN',  30000, 20, '2021-03-15'),
(103, 'JONES',  'MANAGER',   40000, 10, '2019-06-20'),
(104, 'SCOTT',  'ANALYST',   35000, 30, '2022-01-05'),
(105, 'KING',   'MANAGER',   50000, 20, '2018-11-12'),
(106, 'ADAMS',  'CLERK',     25000, 30, '2023-02-18'),
(107, 'MILLER', 'CLERK',     30000, 10, '2021-08-25'),
(108, 'FORD',   'ANALYST',   45000, 20, '2020-09-30'),
(109, 'WARD',   'SALESMAN',  28000, 30, '2022-07-14'),
(110, 'BLAKE',  'MANAGER',   40000, 10, '2019-12-01');


select ename,row_number()over(order by salary) as rownum
from emplo;

select ename,row_number()over(partition by deptno order by salary  ) as rownum
from emplo;

select*, rank()over(partition by deptno order by salary desc) as ranka from emplo;
select*, dense_rank()over(partition by deptno order by salary desc) as ranka from emplo;


select *,ntile(5)over(partition by deptno order by salary)as ntiles
from emp3;


select *,lead(salary,3)over(order by salary) as lags
from emp3;

select *,last_value(ename)over(order by salary rows between unbounded preceding and unbounded following ) as firstvalue
from emp3;

select *,nth_value(ename,2)over(order by salary rows between unbounded preceding and unbounded following ) as firstvalue
from emp3;




CREATE TABLE dept (
    deptno INT PRIMARY KEY,
    dname VARCHAR(30),
    location VARCHAR(30)
);

INSERT INTO dept VALUES
(10, 'ACCOUNTING', 'CHENNAI'),
(20, 'SALES', 'BANGALORE'),
(30, 'RESEARCH', 'HYDERABAD'),
(40, 'HR', 'PUNE'),
(50, 'IT', 'MUMBAI');


CREATE TABLE empjoin (
    emp_id INT PRIMARY KEY,
    ename VARCHAR(30),
    job VARCHAR(30),
    salary DECIMAL(10,2),
    deptno INT,
    manager_id INT
);

INSERT INTO empjoin VALUES
(101, 'SMITH',  'CLERK',    25000, 10, 103),
(102, 'ALLEN',  'SALESMAN', 30000, 20, 105),
(103, 'JONES',  'MANAGER',  40000, 10, NULL),
(104, 'SCOTT',  'ANALYST',  35000, 30, 105),
(105, 'KING',   'MANAGER',  50000, 20, NULL),
(106, 'ADAMS',  'CLERK',    25000, 30, 104),
(107, 'MILLER', 'CLERK',    30000, 10, 103),
(108, 'FORD',   'ANALYST',  45000, 20, 105),
(109, 'WARD',   'SALESMAN', 28000, NULL, 105),
(110, 'BLAKE',  'MANAGER',  40000, 40, NULL);


select e.*,d.*
from empjoin e cross join dept d;


select e.*,d.*  from empjoin e inner join dept d
on e.deptno=d.deptno;



select e.*,d.* from empjoin e right join dept d
on e.deptno=d.deptno;


select e.ename,e2.ename
from empjoin e join empjoin e2
on e.salary>
e2.salary;












































select case when salary>80000 then'High Salary'
when salary between 50000 and 80000 then 'Medium Salary'
else 'Low Salary' end aS salary_category,
count(*) as emp_count
from employee_performance
group by salary_category;

select case when salary>80000 then 'High Salary'
when salary between 50000 and 80000 then 'Medium Salary'
ELSE 'Low Salary' end AS salary_category,
COUNT(*) as emp_count
FROM employee_performance
GROUP by (case WHEN salary>80000 then 'High Salary'
when salary  between 50000 and 80000 then 'Medium Salary'
ELSE 'Low Salary' END) ;


use hospital_db;

select d.*,dep.department_name
from doctors d inner join departments dep
on d.department_id=dep.department_id;


select * from patients
where dob<'1995-01-01';


select * from appointments
where appointment_date between '2025-02-01' and '2025-02-29';
select * from doctors
where consultation_fee between 600 and 800;

select * from medicines
where expiry_date=date_add(curdate(),interval 365 day);


select * from patients
where blood_group='o+' and city ='Bangalore';

select * from doctors
order by experience desc ,salary desc;


select * from patients
where registration_date between '2025-01-01' and '2025-01-30' and insurance_provider not in('Star Health');


select distinct doctors.*,specialization
from doctors;

select * from doctors
where email like '%mail.com';


select a.*,dep.department_name,concat(d.first_name,' ',d.last_name) as doctors_name
from doctors d inner join appointments a
on d.doctor_id=a.doctor_id  inner  join departments dep

on d.department_id=dep.department_id;


select d.first_name,d1.first_name
from doctors d join doctors d1
where d.department_id=d1.department_id;

select p.*,a.appointment_id
from patients p left join appointments a
on p.patient_id=a.patient_id
where a.appointment_id is null;

select * from doctors
where salary>(select avg(salary)
from doctors);


select *
from patients
where 


use hospital_db;
create table employee(emp_id int );
alter table employee
add  ename varchar(30);
alter table employee
add salary  enum('123','1234','1213','456','1243');


 
insert into employee(salary)values('123','1234');
alter table employee
add discount set('12','123','1234','12345');
insert into employee(discount)values('12,123');
alter table employee
add join_date timestamp;


insert into employee(join_date)values(curtime());
insert into employee(join_date)values('2003-01-01 01-01-01');

alter table employee
add bonus int unique;

insert into employee(bonus) values(null);
truncate  table employee;
insert into employee(ename,salary,discount,join_date,bonus) values('vignesh','123','12','2002-02-01',120);


insert into employee(ename,salary,discount,join_date) values('vignesh','123','12','2002-02-01');

insert into employee(ename,salary,discount,join_date) values('veera','1234','123','2002-02-01');

select * from employee;
delete from employees;
































use class;

 create TABLE departmentss (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30),
    location VARCHAR(30)
);

INSERT INTO departmentss VALUES
(10, 'IT', 'Bangalore'),
(20, 'HR', 'Chennai'),
(30, 'SALES', 'Hyderabad'),
(40, 'FINANCE', 'Pune'),
(50, 'MARKETING', 'Mumbai');


select e.*
from departmentss e
where not exists(select 1
from departmentss m
where e.dept_id=m.dept_id);


select * from emp where salary > all(select salary
from emp
where deptid=10);


create table enums(id int primary key,gender enum('male','female'));

insert into enums values(1,'male');


insert into enums values(1,'ale');

create table sets(id int primary key ,skills set('java','pyhton','css'));

insert into sets values(1,'java,pyhton,css');

select * from sets;

create table salariesi(salary int default 1000);


select * from salariesi;

insert into salariesi values();



CREATE TABLE departments1 (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30),
    location VARCHAR(30)
);

INSERT INTO departments1 VALUES
(10, 'IT', 'Bangalore'),
(20, 'HR', 'Chennai'),
(30, 'SALES', 'Hyderabad'),
(40, 'FINANCE', 'Pune'),
(50, 'MARKETING', 'Mumbai');



CREATE TABLE employees1 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(30),
    job VARCHAR(30),
    salary INT,
    dept_id INT,
    manager_id INT
);

INSERT INTO employees1 VALUES
(101, 'Vignesh', 'Developer', 50000, 10, 103),
(102, 'Arun', 'Tester', 35000, 10, 103),
(103, 'Kumar', 'Manager', 70000, 10, NULL),
(104, 'Priya', 'HR', 45000, 20, 105),
(105, 'Divya', 'Manager', 55000, 20, NULL),
(106, 'Ravi', 'Salesman', 30000, 30, 108),
(107, 'Suresh', 'Salesman', 40000, 30, 108),
(108, 'Anu', 'Manager', 60000, 30, NULL),
(109, 'Rahul', 'Accountant', 48000, 40, 110),
(110, 'Meena', 'Manager', 52000, 40, NULL),
(111, 'Karthik', 'Developer', 65000, 10, 103);











CREATE TABLE departments3 (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(30),
    location VARCHAR(30)
);

INSERT INTO departments3 VALUES
(10, 'IT', 'Bangalore'),
(20, 'HR', 'Chennai'),
(30, 'SALES', 'Hyderabad'),
(40, 'FINANCE', 'Pune'),
(50, 'MARKETING', 'Mumbai');


CREATE TABLE employees3 (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(30),
    job VARCHAR(30),
    salary INT,
    dept_id INT,
    manager_id INT
);

INSERT INTO employees3 VALUES
(101, 'Vignesh', 'Developer', 50000, 10, 103),
(102, 'Arun', 'Tester', 35000, 10, 103),
(103, 'Kumar', 'Manager', 70000, 10, NULL),
(104, 'Priya', 'HR', 45000, 20, 105),
(105, 'Divya', 'Manager', 55000, 20, NULL),
(106, 'Ravi', 'Salesman', 30000, 30, 108),
(107, 'Suresh', 'Salesman', 40000, 30, 108),
(108, 'Anu', 'Manager', 60000, 30, NULL),
(109, 'Rahul', 'Accountant', 48000, 40, 110),
(110, 'Meena', 'Manager', 52000, 40, NULL),
(111, 'Karthik', 'Developer', 65000, 10, 103);



select * from employees3
where salary>(select avg(salary)
from employees3);

select *,max(salary)
from employees3;
select *
from employees3
where salary=(select max(salary)
from employees3);

select e.*
from employees3 e
where salary>(select avg(d.salary)
from employees3 d
where e.deptid=d.deptid);




use j2ee_student;
select * from student;
create table vehicle(vehicle_id int primary key,vehicle_name varchar(20) not null,vehicle_color varchar(20) not null,price decimal(5,2));
use j2ee_student;
select * from student;


truncate table student;

alter table student
add password varchar(50);


insert into student values(0,'vugnesh','9787650','vignesh2003asai@gmail.com','vignesh2003'),(0,'veera','97835623','veera@gmail.com','veera2003');



emailemailemail

select * from student;
drop table shop;

select * from shop;



use j2ee_student;
drop table servletstudent;

create table servletstudent(name varchar(20),phone varchar(20),email varchar(20),password varchar(20));

alter table servletstudent add id int primary key auto_increment;






























































































































































































































































































































































































































































































































































































































































































































































































































































