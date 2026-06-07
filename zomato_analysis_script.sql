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









