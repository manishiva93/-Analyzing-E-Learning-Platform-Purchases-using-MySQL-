-- Database Creation and Data Insertion

-- Create database
CREATE DATABASE elearning_purchases;
USE elearning_purchases;

-- Create learners table
CREATE TABLE learners (
    learner_id INT PRIMARY KEY,
    full_name VARCHAR(100),
    country VARCHAR(50)
);

-- Create courses table
CREATE TABLE courses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    category VARCHAR(50),
    unit_price DECIMAL(10,2)
);

-- Create purchases table
CREATE TABLE purchases (
    purchase_id INT PRIMARY KEY,
    learner_id INT,
    course_id INT,
    quantity INT,
    purchase_date DATE,

    FOREIGN KEY (learner_id)
    REFERENCES learners(learner_id),

    FOREIGN KEY (course_id)
    REFERENCES courses(course_id)
);

-- Insert data into learners
INSERT INTO learners
(learner_id, full_name, country)
VALUES
(1, 'Mani Sankar', 'India'),
(2, 'Priya', 'India'),
(3, 'John', 'USA'),
(4, 'Aisha', 'UAE'),
(5, 'David', 'UK');

-- Insert data into courses
INSERT INTO courses
(course_id, course_name, category, unit_price)
VALUES
(101, 'SQL Basics', 'Data Analytics', 1500.00),
(102, 'Power BI', 'Data Analytics', 2500.00),
(103, 'Python Programming', 'Programming', 2000.00),
(104, 'Advanced Excel', 'Data Analytics', 1200.00),
(105, 'Digital Marketing', 'Marketing', 1800.00);

-- Insert data into purchases
INSERT INTO purchases
(purchase_id, learner_id, course_id, quantity, purchase_date)
VALUES
(1, 1, 101, 2, '2026-01-05'),
(2, 1, 102, 1, '2026-01-10'),
(3, 2, 101, 1, '2026-01-12'),
(4, 2, 103, 2, '2026-01-15'),
(5, 3, 102, 2, '2026-01-18'),
(6, 3, 104, 1, '2026-01-20'),
(7, 4, 103, 1, '2026-01-22'),
(8, 4, 101, 3, '2026-01-25');

SELECT * FROM learners;
SELECT * FROM courses;
SELECT * FROM purchases;

-- Data Exploration Using Joins
--  INNER JOIN
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    c.course_name,
    c.category,
    p.quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
ORDER BY total_amount DESC;

-- LEFT JOIN
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    c.course_name,
    c.category,
    p.quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date
FROM learners l
LEFT JOIN purchases p
ON l.learner_id = p.learner_id
LEFT JOIN courses c
ON p.course_id = c.course_id
ORDER BY l.learner_id;

-- RIGHT JOIN
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    c.course_name,
    c.category,
    p.quantity,
    FORMAT(p.quantity * c.unit_price, 2) AS total_amount,
    p.purchase_date
FROM purchases p
RIGHT JOIN courses c
ON p.course_id = c.course_id
LEFT JOIN learners l
ON p.learner_id = l.learner_id
ORDER BY c.course_id;

-- Analytical Queries
-- Q1. Display each learner's total spending along with their country.
SELECT
    l.learner_id,
    l.full_name,
    l.country,
    FORMAT(
        COALESCE(SUM(p.quantity * c.unit_price), 0),
        2
    ) AS total_spending

FROM learners l
LEFT JOIN purchases p
ON l.learner_id = p.learner_id
LEFT JOIN courses c
ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name,
    l.country
ORDER BY
    COALESCE(SUM(p.quantity * c.unit_price), 0) DESC;
    
-- Q2. Find the top 3 most purchased courses based on total quantity sold.
SELECT
    c.course_id,
    c.course_name,
    SUM(p.quantity) AS total_quantity_sold
FROM courses c
INNER JOIN purchases p
ON c.course_id = p.course_id
GROUP BY
    c.course_id,
    c.course_name
ORDER BY
    total_quantity_sold DESC,
    c.course_id
LIMIT 3;

-- Q3. Show each course category's total revenue and number of unique learners.
SELECT
    c.category,

    FORMAT(
        COALESCE(SUM(p.quantity * c.unit_price), 0),
        2
    ) AS total_revenue,

COUNT(DISTINCT p.learner_id)
AS unique_learners
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
GROUP BY c.category
ORDER BY
    SUM(p.quantity * c.unit_price) DESC;
    
-- List all learners who have purchased courses from more than one category.
SELECT
    l.learner_id,
    l.full_name,
    COUNT(DISTINCT c.category) AS total_categories
FROM learners l
INNER JOIN purchases p
ON l.learner_id = p.learner_id
INNER JOIN courses c
ON p.course_id = c.course_id
GROUP BY
    l.learner_id,
    l.full_name
HAVING COUNT(DISTINCT c.category) > 1;

-- Q5. Identify courses that have not been purchased at all.
SELECT
    c.course_id,
    c.course_name,
    c.category,
    c.unit_price
FROM courses c
LEFT JOIN purchases p
ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL;
