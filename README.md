# Swiggy SQL Data Analytics

A complete SQL-based analytics system built to simulate how a real food delivery platform (like Swiggy) stores, processes, and analyzes business data.

This project converts raw CSV files into a structured relational database and generates business-ready insights using SQL.

## Project Overview

Food delivery platforms generate large volumes of transactional data from customers, restaurants, and orders.  
This project demonstrates how such data can be transformed into a clean, queryable data warehouse and used to answer important business questions.

The system is designed using normalized tables, staging layers for data cleaning, and analytical views for reporting.

## Dataset

The project uses multiple CSV files representing different entities of a food delivery platform:

- Cities  
- Restaurants  
- Restaurant Types  
- Customers (Members)  
- Meals  
- Meal Types  
- Serve Types  
- Orders  
- Order Details  

Each file is loaded into MySQL and linked using primary and foreign keys.

## What This Project Does

- Builds a relational database from raw CSV files  
- Cleans and standardizes real-world data (currency, time, city names)  
- Converts text-based values into usable numeric and datetime formats  
- Creates analytical views to support business reporting  
- Simulates how companies analyze food delivery operations  

## Key Analytics Created

The SQL layer generates insights such as:

- Revenue by city and date  
- Restaurant-wise sales and order volume  
- Customer lifetime value  
- Meal popularity and total units sold  
- Cancellation and delivery performance  

These metrics reflect the type of reporting used by food delivery companies to track growth and performance.

## Technology Used

- MySQL 8  
- SQL  
- CSV Data Files  

## How to Run the Project

1. Install MySQL 8  
2. Copy all CSV files into:

   `C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/`

3. Open MySQL Workbench  
4. Run the script:

   `sql/swiggy_analytics.sql`

The script will:
- Create the database  
- Load and clean the data  
- Generate analytics views  

## Why This Project Matters

This project demonstrates practical SQL skills used in real analytics roles, including:

- Database design  
- Data ingestion and transformation  
- Business KPI creation  
- Multi-table joins and aggregations  

It reflects how data analysts work with transactional data in production environments.
