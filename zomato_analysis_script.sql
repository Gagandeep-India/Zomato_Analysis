#Database AND tables creation

CREATE DATABASE zomato_db;

USE zomato_db;

DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS riders;
DROP TABLE IF EXISTS deliveries;

CREATE TABLE customers
( 
	customer_id INT PRIMARY KEY,
    customer_name VARCHAR(25) NOT NULL,
    reg_date DATE
);
    

CREATE TABLE orders
(
	order_id INT PRIMARY KEY,
    customer_id INT, 
	restaurant_id INT,
	order_item VARCHAR(20),
	order_date DATE NOT NULL,
	order_time TIME NOT NULL,
	order_status VARCHAR(20) DEFAULT 'Pending',
	total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id)  REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE deliveries
(
	delivery_id INT PRIMARY KEY,
	order_id INT,
	delivery_status VARCHAR(50) DEFAULT 'Pending',
	delivery_time TIME,
	rider_id INT,  
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (rider_id) REFERENCES riders(rider_id)
);

CREATE TABLE riders
(	rider_id INT PRIMARY KEY,
	rider_name VARCHAR(60) NOT NULL,
	sign_up DATE
);

CREATE TABLE restaurants
(
	restaurant_id INT PRIMARY KEY,
	restaurant_name VARCHAR(60) NOT NULL,
	city VARCHAR(50),
	opening_hours VARCHAR(20)
);

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM deliveries;
SELECT * FROM riders;
SELECT * FROM restaurants;

# Cleaning

SELECT COUNT(*)
FROM customers
WHERE 
customer_id IS NULL
OR 
customer_name IS NULL
OR 
reg_date IS NULL;

SELECT COUNT(*)
FROM restaurants
WHERE
restaurant_id IS NULL
OR
restaurant_name IS NULL
OR
city IS NULL
OR
opening_hours IS NULL;

SELECT COUNT(*) 
FROM orders
WHERE
order_id IS NULL
OR
customer_id IS NULL
OR
restaurant_id IS NULL
OR
order_item IS NULL
OR
order_date IS NULL
OR
order_time IS NULL
OR
order_status IS NULL
OR
total_amount IS NULL;

-- let's insert some null values and check for understanding that's it

INSERT INTO orders(order_id, customer_id, restaurant_id, order_date, order_time, total_amount)
VALUES
	(10002, 2, 5, '2026-06-07', '13:00:01', 900),
    (10003, 3, 7,'2026-06-07', '13:00:01', 1000),
    (10005, 1, 7,'2026-06-07', '13:00:00', 1002);
    
DELETE FROM 
orders
WHERE
order_id IS NULL
OR
customer_id IS NULL
OR
restaurant_id IS NULL
OR
order_item IS NULL
OR
order_date IS NULL
OR
order_time IS NULL
OR
order_status IS NULL
OR
total_amount IS NULL;


SELECT COUNT(*)
FROM riders
WHERE
rider_id IS NULL
OR
rider_name IS NULL
OR
sign_up IS NULL;

SELECT COUNT(*)
FROM deliveries
WHERE
delivery_id IS NULL
OR
order_id IS NULL
OR
delivery_status IS NULL
OR
delivery_time IS NULL
OR
rider_id IS NULL;

# Analysis

-- 1.query to find the top 5 most frequently ordered dishes by the customer called 'Arjun Mehta' in the year 2023

SELECT * 
FROM orders;
 
WITH 
t1
AS(
SELECT 
	o.customer_id,
    c.customer_name,
    order_item AS dishes,
	COUNT(*) as total_orders,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS 'rank'
FROM orders o
JOIN customers c
USING (customer_id)
WHERE
		customer_name = 'Arjun Mehta' AND 
        order_date BETWEEN '2023-01-01' AND '2024-01-01'
GROUP BY o.customer_id, c.customer_name, order_item
ORDER BY total_orders DESC
) 
SELECT 
    customer_name,
    dishes,
    total_orders
FROM t1
WHERE `rank` <= 5;

-- to get all the orders past 1 year considering till today as 1 year then CURRENT_DATE - INTERVAL '1 Year'


-- SELECT CURRENT_DATE - INTERVAL 1 YEAR

-- 2.  Popular time analysis
#Identify the time slots in which most of the orders are placed.Based on 2-hour interval
SELECT 
	CASE 
		 WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1  THEN '00:00 - 02:00'
		 WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3  THEN '02:00 - 04:00'	
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5  THEN '04:00 - 06:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7  THEN '06:00 - 08:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9  THEN '08:00 - 10:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
	END AS time_slot,
    COUNT(*) AS nr_of_orders
FROM orders
GROUP BY time_slot
ORDER BY nr_of_orders DESC;

-- or 
SELECT
	FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_time,
    FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 + 2 AS end_time,
    COUNT(*) AS orders
FROM orders
GROUP BY 1, 2
ORDER BY orders DESC;

-- 3.Order value analysis
-- question find the avg order value per customer who has placed more than 500 orders.
-- return customer name, and aov(average order value)

SELECT 
	customer_name,
    avg_order_value
FROM 
(
SELECT 
	customer_name,
    AVG(total_amount) AS avg_order_value,
    COUNT(order_id) AS total_orders
FROM orders o
JOIN customers c USING(customer_id)
GROUP BY customer_name
) AS t2 WHERE total_orders > 500;

-- or

SELECT 
	customer_name,
    AVG(total_amount) AS avg_order_value
FROM orders o
JOIN customers c USING(customer_id)
GROUP BY customer_id, customer_name
HAVING  COUNT(order_id) > 500;

-- 4.high value customers
-- question:list the customers who have spent more than 100k in total in food orders
-- return the customer_name and customer_id

SELECT 
	customer_id,
	customer_name
-- 	SUM(total_amount) AS '>100k'
FROM orders o
JOIN customers c
USING (customer_id)
GROUP BY 1, 2
HAVING SUM(total_amount) > 100000;

-- 5.Orders without deliery
-- find the orders that were placed but not delivered
-- return restaurant's name, city and number of not delivered orders
SELECT * FROM orders, deliveries, restaurants;

SELECT  
    r.restaurant_name,
    r.city,
    COUNT(d.order_id) AS nd_fucks
FROM orders o 
LEFT JOIN restaurants r USING(restaurant_id)
LEFT JOIN deliveries d USING(order_id)
WHERE d.delivery_id IS NULL
GROUP BY 1, 2
ORDER BY nd_fucks DESC;

SELECT 
	 r.restaurant_name,
     r.city,
     COUNT(o.order_id) AS nd_fucks
FROM orders o 
LEFT JOIN restaurants r USING(restaurant_id)
LEFT JOIN deliveries d USING(order_id)
WHERE o.order_id NOT IN (SELECT order_id FROM deliveries) 
GROUP BY 1, 2
ORDER BY nd_fucks DESC





















