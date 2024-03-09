-- Create database
CREATE DATABASE IF NOT EXISTS amazonSales;
use  amazonsales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating DECIMAL(3, 1)
);

-- Data cleaning
SELECT *
FROM sales;


-- Add the time_of_day column
SELECT
	time,
	(CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;


ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (
	CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);





-- Add day_name column
SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);



-- Add month_name column
SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


# Questions
-- What is the count of distinct cities in the dataset?
SELECT 
	DISTINCT city
FROM sales;

-- For each branch, what is the corresponding city?
SELECT 
	DISTINCT city,
    branch
FROM sales;

-- What is the count of distinct product lines in the dataset?
SELECT
	DISTINCT product_line, count(*) as count
FROM sales
group by 1
order by 2 desc;

-- Which payment method occurs most frequently?
SELECT payment_method, COUNT(*) AS frequency
FROM sales
GROUP BY payment_method
ORDER BY frequency DESC;

-- Which product line has the highest sales?
SELECT
	product_line, SUM(quantity) as qty
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- How much revenue is generated each month?
SELECT
	month_name AS month,
	SUM(total) AS total_revenue
FROM sales
GROUP BY month_name 
ORDER BY total_revenue desc;

-- In which month did the cost of goods sold reach its peak?
SELECT
	month_name AS month,
	SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs DESC;

-- Which product line generated the highest revenue?
SELECT
	product_line,
	SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- In which city was the highest revenue recorded?
SELECT
	branch,
	city,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue desc;

-- Which product line incurred the highest Value Added Tax?
SELECT
	product_line,
	AVG(tax_pct) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- For each product line, add a column indicating "Good" 
-- if its sales are above average, otherwise "Bad."
SELECT 
	product_line,
	ROUND(AVG(total),2) AS avg_sales,
	(CASE
		WHEN AVG(total) > (SELECT AVG(total) FROM sales) THEN "Good"
        ELSE "Bad"
	END) AS Criteria
FROM sales
GROUP BY product_line
ORDER BY avg_sales;
-- AVG total = 322.97 


-- Identify the branch that exceeded the average number of products sold.
SELECT 
	branch, 
    SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- Which product line is most frequently associated with each gender?
SELECT
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- Calculate the average rating for each product line.
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Count the sales occurrences for each time of day on every weekday.
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Identify the customer type contributing the highest revenue.
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue desc;

-- Determine the city with the highest VAT percentage. 
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Identify the customer type with the highest VAT payments.
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- What is the count of distinct customer types in the dataset?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- What is the count of distinct payment methods in the dataset?
SELECT
	 payment_method,
     count(*) as count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;

-- Which customer type occurs most frequently?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Identify the customer type with the highest purchase frequency.
SELECT
	customer_type,
    COUNT(*) as purchase_frequency
FROM sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

-- Determine the predominant gender among customers.
SELECT
	gender,
	COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- Examine the distribution of genders within each branch.
SELECT 
    branch,
    gender,
    COUNT(*) AS gender_count
FROM sales
GROUP BY branch, gender
order by 1;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Identify the time of day when customers provide the most ratings.
SELECT
	time_of_day,
	round(avg(rating),2) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.

-- Determine the time of day with the highest customer ratings for each branch.
SELECT 
	branch,
    time_of_day,
	round(avg(rating),2) AS avg_rating
FROM sales
GROUP BY branch,time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.

-- Identify the day of the week with the highest average ratings.
SELECT
	day_name,
	round(avg(rating),2) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings

-- Determine the day of the week with the highest average ratings for each branch.
SELECT 
    branch,
	day_name,
	round(avg(rating),2) AS avg_rating
FROM sales
GROUP BY branch, day_name
ORDER BY branch, avg_rating DESC;

-- Finished --



