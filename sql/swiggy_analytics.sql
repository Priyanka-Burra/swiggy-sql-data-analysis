DROP DATABASE IF EXISTS swiggy_analytics;
CREATE DATABASE swiggy_analytics;
USE swiggy_analytics;

CREATE TABLE cities (
    city_id INT,
    city_name VARCHAR(100)
);

CREATE TABLE restaurant_types (
    restaurant_type_id INT,
    restaurant_type_name VARCHAR(100)
);

CREATE TABLE serve_types (
    serve_type_id INT,
    serve_type_name VARCHAR(50)
);

CREATE TABLE meal_types (
    meal_type_id INT,
    meal_type_name VARCHAR(100)
);

CREATE TABLE restaurants (
    restaurant_id INT,
    restaurant_name VARCHAR(200),
    restaurant_type_id INT,
    city_id INT
);

CREATE TABLE members (
    member_id INT,
    member_name VARCHAR(100),
    city_id INT
);

CREATE TABLE meals (
    meal_id INT,
    restaurant_id INT,
    serve_type_id INT,
    meal_type_id INT,
    hot_cold VARCHAR(20),
    meal_name VARCHAR(200),
    price DECIMAL(10,2)
);

CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    hour INT,
    member_id INT,
    restaurant_id INT,
    total_amount DECIMAL(10,2),
    status VARCHAR(50),
    city_id INT
);

CREATE TABLE order_details (
    order_id INT,
    meal_id INT,
    quantity INT,
    price DECIMAL(10,2)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cities.csv'
INTO TABLE cities
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/restaurant_types.csv'
INTO TABLE restaurant_types
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/serve_types.csv'
INTO TABLE serve_types
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/meal_types.csv'
INTO TABLE meal_types
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

DROP TABLE IF EXISTS restaurants_stage;

CREATE TABLE restaurants_stage (
    restaurant_id INT,
    restaurant_name VARCHAR(200),
    restaurant_type_id INT,
    income_percentage DECIMAL(6,3),
    city_id INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/restaurants.csv'
INTO TABLE restaurants_stage
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

INSERT INTO restaurants
SELECT restaurant_id, restaurant_name, restaurant_type_id, city_id
FROM restaurants_stage;

DROP TABLE restaurants_stage;

DROP TABLE IF EXISTS members_stage;

CREATE TABLE members_stage (
    member_id INT,
    member_name VARCHAR(100),
    city_name VARCHAR(100),
    status VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/members.csv'
INTO TABLE members_stage
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @member_id,
    member_name,
    city_name,
    status,
    @d1,@d2,@d3,@d4,@d5
)
SET member_id = NULLIF(TRIM(@member_id), '');

INSERT INTO members (member_id, member_name, city_id)
SELECT m.member_id, m.member_name, c.city_id
FROM members_stage m
JOIN cities c ON TRIM(m.city_name) = TRIM(c.city_name);

DROP TABLE members_stage;

CREATE TABLE orders_stage (
    order_id INT,
    order_date DATE,
    order_time_raw VARCHAR(30),
    member_id INT,
    restaurant_id INT,
    total_amount_raw VARCHAR(50)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/orders.csv'
INTO TABLE orders_stage
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

INSERT INTO orders (order_id, order_date, hour, member_id, restaurant_id, total_amount)
SELECT
    order_id,
    order_date,
    HOUR(STR_TO_DATE(SUBSTRING_INDEX(order_time_raw,'.',1), '%H:%i:%s')),
    member_id,
    restaurant_id,
    CAST(REPLACE(REPLACE(total_amount_raw, '₹', ''), ',', '') AS DECIMAL(10,2))
FROM orders_stage;

DROP TABLE orders_stage;

UPDATE orders o
JOIN members m ON o.member_id = m.member_id
SET o.city_id = m.city_id;

UPDATE orders
SET status = 'Delivered';

CREATE VIEW revenue_summary AS
SELECT o.order_date, c.city_name, SUM(o.total_amount) AS revenue
FROM orders o
JOIN cities c ON o.city_id = c.city_id
WHERE o.status='Delivered'
GROUP BY o.order_date, c.city_name;

CREATE VIEW restaurant_kpis AS
SELECT r.restaurant_name,
       COUNT(o.order_id) AS total_orders,
       SUM(o.total_amount) AS revenue
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.status='Delivered'
GROUP BY r.restaurant_name;

CREATE VIEW cancellation_kpis AS
SELECT c.city_name,
       COUNT(CASE WHEN o.status='Cancelled' THEN 1 END)*100.0/COUNT(*) AS cancel_rate
FROM orders o
JOIN cities c ON o.city_id = c.city_id
GROUP BY c.city_name;

CREATE VIEW customer_value AS
SELECT m.member_name,
       COUNT(o.order_id) AS total_orders,
       SUM(o.total_amount) AS lifetime_value
FROM orders o
JOIN members m ON o.member_id = m.member_id
WHERE o.status='Delivered'
GROUP BY m.member_name;

CREATE VIEW meal_popularity AS
SELECT m.meal_name,
       SUM(od.quantity) AS total_sold,
       SUM(od.quantity * od.price) AS revenue
FROM order_details od
JOIN meals m ON od.meal_id = m.meal_id
GROUP BY m.meal_name;

SELECT COUNT(*) AS orders FROM orders;
SELECT COUNT(*) AS members FROM members;
SELECT COUNT(*) AS restaurants FROM restaurants;
SELECT COUNT(*) AS revenue_rows FROM revenue_summary;
