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
		 WHEN  EXTRACT(HOUR FROM order_time) BETWEEN  0 AND 1   THEN '00:00 - 02:00'
		 WHEN  EXTRACT(HOUR FROM order_time) BETWEEN  2 AND 3   THEN '02:00 - 04:00'	
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN  4 AND 5   THEN '04:00 - 06:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN  6 AND 7   THEN '06:00 - 08:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN  8 AND 9   THEN '08:00 - 10:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11  THEN '10:00 - 12:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13  THEN '12:00 - 14:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15  THEN '14:00 - 16:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17  THEN '16:00 - 18:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19  THEN '18:00 - 20:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21  THEN '20:00 - 22:00'
         WHEN  EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23  THEN '22:00 - 00:00'
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
) AS t2 WHERE total_orders > 750;

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
ORDER BY nd_fucks DESC;

-- 6.Restaurant Revenue ranking:
-- rank restaurants by their total revenue from the last year including their name, total revenue and rank within their city
SELECT * 
FROM restaurants;

SELECT * 
FROM orders;

SELECT
    r.city,
    r.restaurant_name,
    SUM(o.total_amount) AS total_revenue,
    RANK() OVER(PARTITION BY r.city ORDER BY SUM(o.total_amount) DESC) AS rank_over_city
FROM restaurants r
LEFT JOIN orders o USING(restaurant_id)
WHERE order_date BETWEEN '2023-01-01' AND '2024-01-01' -- CURRENT_DATE() - INTERVAL 1 Year --  
GROUP BY 1, 2;
-- ORDER BY r.city, total_revenue DESC;

-- 7. Most popular dish by city:
-- Identify the most popular dish in a city based on number of orders

SELECT *
FROM orders;

WITH 
t1_cte
AS
(
SELECT
	r.city,
	order_item,
    COUNT(*) as no_of_orders,
    RANK() OVER(PARTITION BY r.city ORDER BY COUNT(*) DESC) AS ranked
FROM orders o 
LEFT JOIN restaurants r USING(restaurant_id)
GROUP BY r.city, order_item
-- ORDER BY no_of_orders DESC
)

SELECT *
FROM t1_cte 
WHERE ranked = 1
ORDER BY no_of_orders DESC;


-- 8.Customer churn
-- Find customers who have not placed an order in 2024 but did in 2023

SELECT * FROM orders;

SELECT 
	DISTINCT customer_id
    
FROM orders o
WHERE EXTRACT(YEAR FROM order_date) = 2023 AND 
      customer_id NOT IN (SELECT DISTINCT customer_id FROM orders 
      WHERE EXTRACT(YEAR FROM order_date = 2024));
      

-- 9.Cancellation Rate comparision
-- Calculate and compare the order cancellation rate for each restaurant between the current year and previous year
																												   
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM deliveries;
SELECT * FROM customers;

-- 2023 CTE
WITH 
cte_2023
AS
(
SELECT 
	o.restaurant_id,
    COUNT(order_id) AS total_orders,
    COUNT(CASE WHEN d.delivery_id is NULL THEN 1 END) not_delivered,
    ROUND(COUNT(CASE WHEN d.delivery_id is NULL THEN 1 END) / COUNT(order_id) * 100, 2) AS cancellation_rate
FROM orders o
-- LEFT JOIN restaurants r USING(restaurant_id)
LEFT JOIN deliveries d USING(order_id)
WHERE EXTRACT(YEAR FROM order_date) = '2023'
GROUP BY 1
ORDER BY not_delivered DESC
),
-- 2024 CTE
cte_2024
AS
(
SELECT 
	o.restaurant_id,
    COUNT(order_id) AS total_orders,
    COUNT(CASE WHEN d.delivery_id is NULL THEN 1 END) not_delivered,
    ROUND(COUNT(CASE WHEN d.delivery_id is NULL THEN 1 END) / COUNT(order_id) * 100, 2) AS cancellation_rate
FROM orders o
-- LEFT JOIN restaurants r USING(restaurant_id)
LEFT JOIN deliveries d USING(order_id)
WHERE EXTRACT(YEAR FROM order_date) = '2024'
GROUP BY 1
ORDER BY not_delivered DESC
)

SELECT 
	cte_2023.restaurant_id,
    cte_2023.cancellation_rate AS '2023 rate',
    cte_2024.cancellation_rate AS '2024 rate'
FROM cte_2023 
JOIN cte_2024 USING(restaurant_id);

-- 10.Rider AVG delivery time
-- determnine rider's average delivery time

SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM deliveries;
SELECT * FROM riders;

-- usage of timestampdiff function to get in seconds not interval
WITH
t1_cte
AS
(
SELECT 
	order_id,
    rider_id,
    TIMESTAMPDIFF(
    MINUTE,
    order_time,
    delivery_time + INTERVAL (delivery_time < order_time) DAY
) AS time_difference
    -- UNIX_TIMESTAMP(delivery_time - order_time + 
--     CASE WHEN delivery_time < order_time THEN INTERVAL 1 day ELSE INTERVAL 0 day END) / 60 AS time_difference
FROM orders o 
JOIN deliveries d USING(order_id)
WHERE delivery_status = 'Delivered'
)

SELECT 
	rider_id,
    AVG(time_difference) AS avg_time
FROM t1_cte
GROUP BY rider_id
ORDER BY avg_time DESC;


-- 11.Monthly restaurant growth ratio:
-- calculate the growth ratio of each restaurant based on total number of delivered orders since it's joining
SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM deliveries;

WITH
growth_cte
AS
(
SELECT 
	restaurant_id,
    DATE_FORMAT(order_date, '%m-%Y') AS month_,
    LAG(COUNT(order_id), 1) OVER(PARTITION BY o.restaurant_id ORDER BY DATE_FORMAT(order_date, '%m-%Y')) AS prev_month_orders,
    COUNT(order_id) AS current_month
FROM orders o 
JOIN deliveries USING(order_id)
WHERE delivery_status = 'Delivered'
GROUP BY 1, 2
)

SELECT *,
	ROUND(((current_month - prev_month_orders) / prev_month_orders) * 100, 2)AS growth_ratio
FROM 
growth_cte;

-- Q.12 Customer segmentation
-- Segment customers into 'gold' or 'silver' groups based on their spendings
-- compared to the AOV if the customer's spending exceeds the AOV then gold else silver
-- sql query to determine each segment's total number of orders and total revenue

SELECT * FROM restaurants;
SELECT * FROM orders;
SELECT * FROM deliveries;
SELECT * FROM customers;


WITH 
category_cte
AS
(
SELECT 
	customer_id,
    SUM(total_amount) AS spending,
    COUNT(*) AS no_orders,
    CASE WHEN SUM(total_amount) > (SELECT AVG(total_amount) FROM orders) THEN 'Gold' ELSE 'Silver'
    END AS 'category'
FROM orders o
GROUP BY customer_id
)

SELECT 
	category,
    SUM(no_orders) AS no_of_orders,
    SUM(spending) AS spending
FROM category_cte
GROUP BY category;

-- 13 Rider's monthly earnings.
-- calculate each rider's total monthly earnings, assuming they earn 8% of the order amount

SELECT * FROM riders;
SELECT * FROM orders;
SELECT * FROM deliveries;

WITH
rider_earning 
AS
(
SELECT 
	order_id,
    rider_id,
    DATE_FORMAT(order_date, '%m-%Y') AS months,
    SUM(total_amount) * 0.08 AS rider_revenue
FROM orders o 
JOIN deliveries d
USING(order_id)
GROUP BY 1, 2, 3
)

SELECT 
	rider_id,
    months,
    ROUND(SUM(rider_revenue), 2) earned_monthly
FROM rider_earning
GROUP BY 1, 2
ORDER BY rider_id, months;

-- OR

SELECT 
    rider_id,
    DATE_FORMAT(order_date, '%m-%Y') AS months,
    ROUND(SUM(total_amount), 2) AS revenue,
    ROUND(SUM(total_amount) * 0.08, 2) AS rider_revenue
FROM orders o 
JOIN deliveries d
USING(order_id)
GROUP BY 1, 2
ORDER BY 1, 2;

-- SELECT 
-- 	rider_id,
--     order_date
-- FROM orders o
-- JOIN deliveries d
-- USING (order_id)
-- WHERE order_date > '2024-01-01';

-- 14.Rider ratings anlysis:
-- Find the number of 5-star, 4-star, 3-star ratings each rider has
-- Riders receive this rating badsed on delivery_time
-- If orders are ordered less than 15 minutes of order time then 5 star
-- between 15 - 20 mins then 4 star
-- after 20 minute it's 3 star

SELECT * FROM orders;
SELECT * FROM restaurants;
SELECT * FROM deliveries;



SELECT 
	rider_id, 
    ratings,
    COUNT(*) AS no_of_ratings
FROM 
(	
	SELECT 
		rider_id, 
		CASE WHEN delivery_time < 15 THEN '5-star' 
			WHEN delivery_time BETWEEN 15 AND 20 THEN '4-star'
			ELSE '3-star' 
		END AS ratings
	FROM 
	(
		SELECT
		rider_id,
		TIMESTAMPDIFF(
			MINUTE,	
			order_time,	
			delivery_time + INTERVAL (delivery_time < order_time)  DAY)
		AS delivery_time
	FROM orders o 
	JOIN deliveries d
	USING (order_id)
	WHERE delivery_status = 'Delivered'
	)AS t1
)AS t2
GROUP BY rider_id, ratings
ORDER BY rider_id;

-- 15.Order frequency by day 
-- Analyse the order frequency per day of the week and identify the peak day for each restaurant

SELECT * FROM orders;
SELECT * FROM restaurants;

WITH 
ranking_restos
AS
(
	SELECT 
		restaurant_id, 
		restaurant_name,
        city,
		DAYNAME(order_date) AS day_,
		COUNT(order_id) AS no_of_orders,
		RANK() OVER(PARTITION BY restaurant_id ORDER BY COUNT(order_id) DESC) AS rank_
	FROM orders o 
	JOIN restaurants r 
	USING(restaurant_id)
	GROUP BY restaurant_id, restaurant_name, DAYNAME(order_date)
)
SELECT *
FROM ranking_restos
WHERE rank_ = 1;


-- 16.Customer lifetime value(CLV)
-- Calculate the total_revenue generated by each customer over all their orders

SELECT
	customer_id,
    SUM(total_amount) AS CLV
FROM orders
GROUP BY customer_id
ORDER BY CLV DESC;

-- 17 Monthly sales trend
-- Identify sales trend by comparing each month's total sales to the previous month

WITH 
t1
AS
 (
SELECT 
	EXTRACT(YEAR FROM order_date) AS year_,
    EXTRACT(MONTH FROM order_date) AS month_,
    LAG(SUM(total_amount), 1) OVER(ORDER BY EXTRACT(YEAR FROM order_date ), EXTRACT(MONTH FROM order_date)) AS prev_month_sales,
    SUM(total_amount) AS current_month_sales
FROM orders
GROUP BY 1, 2
ORDER BY 1, 2
)
SELECT
	*,
    ROUND((current_month_sales - prev_month_sales) / prev_month_sales * 100, 2) AS growth_ratio_in_per
FROM t1;

-- 18 Rider efficiency
-- evaluate rider efficiency by determining the average delivery times and identifying those with the lowest and highest aveages.

WITH 
rider_efficiency
AS
  (
	SELECT 
		rider_id,
		TIMESTAMPDIFF(
			MINUTE,
			order_time,
			delivery_time + INTERVAL (delivery_time < order_time) DAY
		) AS delivery_time
	FROM orders o 
	JOIN deliveries d USING(order_id)
	WHERE delivery_status = 'Delivered'
   ),
rider_avg_time
AS 
(
	SELECT 
		rider_id,
		ROUND(AVG(delivery_time), 2) AS avg_time
	FROM rider_efficiency
	GROUP BY rider_id 
	ORDER BY 2 DESC
)

SELECT 
    MAX(avg_time),
    MIN(avg_time)
FROM rider_avg_time;

-- 19 Order Item popularity
-- track the popularity of specific order items and identify seasonal demand spike

SELECT * FROM orders;

SELECT *
FROM 
(
SELECT
	*,
    RANK() OVER(PARTITION BY order_item ORDER BY no_of_orders DESC) AS rank_
FROM 
(
SELECT 
	order_item,
    CASE
        WHEN MONTH(order_date) IN (3, 4, 5) THEN 'Summer'
        WHEN MONTH(order_date) IN (6, 7, 8, 9) THEN 'Monsoon'
        WHEN MONTH(order_date) IN (10, 11) THEN 'Post-Monsoon'
        WHEN MONTH(order_date) IN (12, 1, 2) THEN 'Winter'
    END AS season,
    COUNT(order_id) AS no_of_orders
FROM orders 
GROUP BY 1, 2 
)AS seasonal_ranks
)AS rank_1
WHERE rank_ = 1
ORDER BY no_of_orders DESC;

-- 20 Rank each city based on the total revenue for last year 2023

SELECT * FROM orders;
SELECT * FROM restaurants;

SELECT 
	city,
    SUM(total_amount) AS total_revenue,
    RANK() OVER(ORDER BY(SUM(total_amount)) DESC) AS ranking
FROM orders o 
JOIN restaurants r
USING(restaurant_id)
WHERE order_date BETWEEN '2023-01-01' AND '2024-01-01'
GROUP BY city




























