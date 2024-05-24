SELECT * FROM cust; -- 129,113 rows
SELECT * FROM fx; -- 168 rows
SELECT * FROM trans; -- 217,977 rows
SELECT * FROM merged; -- 217,757 rows
------------------------------------------------------------------------
------------------------------------------------------------------------
-- Understanding the data

--Amount of products
SELECT DISTINCT(product_id) as pd FROM merged;
--207,459

--Amount of puchases
SELECT DISTINCT(product_id) as pd FROM merged;
--207,459

--Amount of regions
SELECT DISTINCT(country) as dc, COUNT(country) as cc
FROM merged
GROUP BY dc
ORDER BY cc desc;
-- 7 regions

--Amount of departments
SELECT DISTINCT(department) as dc, COUNT(department) as cc
FROM merged
GROUP BY dc
ORDER BY cc desc;
-- 9 departments

-- Amount of products
SELECT DISTINCT(category) as dc, COUNT(category) as cc
FROM merged
GROUP BY dc
ORDER BY cc desc;
-- 15 categories

-- Amount of buyers and amount of purchases
SELECT DISTINCT(buyer_id) AS db,COUNT(purchase_id) AS cp
FROM merged
GROUP BY db
ORDER BY cp desc;
-- 129,113

---Timeframe
SELECT DISTINCT(purchase_date) as dc, COUNT(purchase_date) as cc
FROM merged
GROUP BY dc
ORDER BY cc desc;
-- 1 week 

-- Most paid currencies
SELECT DISTINCT(currency) as dc, COUNT(currency) as cc
FROM merged
GROUP BY dc
ORDER BY cc desc;
-- 1 week 

------------------------------------------------------------------------
------------------------------------------------------------------------

--1. The client has provided transactional data. By analysing this data:

--a. Tell us which are the best-selling products, by region and department.

SELECT * FROM merged; -- 217,977 rows

-- Best selling product in count
SELECT DISTINCT(product_id), category, COUNT(product_id) AS total_count, SUM(value_in_gbp) AS total_value_in_gbp
FROM merged
GROUP BY (product_id), category
ORDER BY total_count DESC
LIMIT 5;

-- What are the top selling departments
SELECT department, SUM(value_in_gbp) AS total_value_in_gbp
FROM merged
GROUP BY department
ORDER BY total_value_in_gbp DESC;

-- Top selling countries
SELECT country, SUM(value_in_gbp) AS total_value_in_gbp
FROM merged
GROUP BY country
ORDER BY total_value_in_gbp DESC;

--b. What other key insights & observations can be drawn from the data?

-- What Gender contributes the most
SELECT gender, COUNT(gender) AS gndr, SUM(value_in_gbp) AS sum
FROM merged
GROUP BY gender;

-- How do age groups differ?
SELECT age_group, COUNT(age_group) AS ag, SUM(value_in_gbp) AS sum
FROM merged
GROUP BY age_group
ORDER by ag desc;

--What insight can membership length give us?
SELECT membership_length, COUNT(membership_length) as cm, SUM(value_in_gbp) AS ml
FROM merged
GROUP BY membership_length
ORDER BY ml desc;

------------------------------------------------------------------------
------------------------------------------------------------------------

--2. The client has also provided you with demographic customer data about each buyer:

--a. How would you approach merging the two datasets, and what considerations do you need to make when doing this?
-- Null rows, more transaction rows than cust rows
--

--b. What additional observations can you gain about the client's customers and their behaviour?

SELECT * FROM merged; -- 217,977 rows
  
SELECT purchase_date, COUNT(purchase_date) AS pd
FROM merged
GROUP BY purchase_date
ORDER BY pd desc;

SELECT buyer_id, COUNT(purchase_id) as pc, gender, age_group, membership_length, SUM(value_in_gbp)
FROM merged
GROUP BY buyer_id,gender, age_group, membership_length, gender;


------------------------------------------------------------------------
------------------------------------------------------------------------

--3. The client wants to improve commercial performance by making data-driven business decisions. What additional information or data would help them to achieve this, and how would you go about combining them into a performance focused report? Consider the below points.

--a. High/ low performing demographics.
-- Female > Male
-- (30-40), (40-50), (18-30), (50-60), (60+)

--b. Additional datasets we would like access to.
--Seasonal Data
--Website Analytics Data
--Customer Feedback and Reviews
--Inventory and Supply Chain Data

--c. Considerations for creating a visual report.
-- Clarity and Simplicity, Audience Understanding, Consistency, Actionable Insights, Interactivity


--d. Tests or further analysis could we propose to drive future performance.
--Customer Segmentation Analysis, Cohort Analysis, A/B Testing for Marketing Campaigns, Predictive Modeling



--

-- Data cubes


SELECT * FROM department_purchases_age_group;

WITH agePopularity AS (
    SELECT 
        age_group, 
        department, 
        COUNT(purchase_id) AS total_count,
        ROW_NUMBER() OVER (PARTITION BY age_group ORDER BY SUM(value_of_item) DESC) AS rn
    FROM merged
    GROUP BY age_group, department
)
SELECT age_group, department, total_count
FROM agePopularity
WHERE rn = 1;

WITH countryPopularity AS (
    SELECT 
        country, 
        department, 
        COUNT(purchase_id) AS total_count,
        ROW_NUMBER() OVER (PARTITION BY country ORDER BY SUM(value_of_item) DESC) AS rn
    FROM merged
    GROUP BY country, department
)
SELECT country, department, total_count
FROM countryPopularity
WHERE rn = 1;

WITH DepartmentPopularity AS (
    SELECT 
        department, 
        category, 
        SUM(value_of_item) AS total_value,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY SUM(value_of_item) DESC) AS rn
    FROM merged
    GROUP BY department, category
)
SELECT department, category, total_value
FROM DepartmentPopularity
WHERE rn = 1;

-- Create Data cubes


-- Customer segmentation of age_groups via departments
CREATE TABLE department_purchases_age_group AS 
SELECT 
    age_group,
    department,
    SUM(value_in_gbp) AS total_value
FROM 
    merged
GROUP BY 
    age_group, department
ORDER BY 
    age_group, department;

SELECT DISTINCT(department) FROM merged;

SELECT 
    age_group,
    SUM(CASE WHEN department = 'Accessories' THEN total_value ELSE 0 END) AS Accessories,
    SUM(CASE WHEN department = 'Beauty' THEN total_value ELSE 0 END) AS Beauty,
    SUM(CASE WHEN department = 'Home' THEN total_value ELSE 0 END) AS Home,
    SUM(CASE WHEN department = 'Jewellery' THEN total_value ELSE 0 END) AS Jewellery,
    SUM(CASE WHEN department = 'Kids' THEN total_value ELSE 0 END) AS Kids,
    SUM(CASE WHEN department = 'Mens apparel' THEN total_value ELSE 0 END) AS Mens,
    SUM(CASE WHEN department = 'Tech' THEN total_value ELSE 0 END) AS Tech,
    SUM(CASE WHEN department = 'Shoes' THEN total_value ELSE 0 END) AS Shoes,
    SUM(CASE WHEN department = 'Womens apparel' THEN total_value ELSE 0 END) AS Womens
FROM 
    department_purchases_age_group
GROUP BY 
    age_group
ORDER BY 
    age_group;
    

-- Customer segmentation of gender via departments
CREATE TABLE department_purchases_gender AS 
SELECT 
    gender,
    department,
    SUM(value_in_gbp) AS total_value
FROM 
    merged
GROUP BY 
    gender, department
ORDER BY 
    gender, department;
    
SELECT * FROM department_purchases_gender;

SELECT 
    gender,
    SUM(CASE WHEN department = 'Accessories' THEN total_value ELSE 0 END) AS Accessories,
    SUM(CASE WHEN department = 'Beauty' THEN total_value ELSE 0 END) AS Beauty,
    SUM(CASE WHEN department = 'Home' THEN total_value ELSE 0 END) AS Home,
    SUM(CASE WHEN department = 'Jewellery' THEN total_value ELSE 0 END) AS Jewellery,
    SUM(CASE WHEN department = 'Kids' THEN total_value ELSE 0 END) AS Kids,
    SUM(CASE WHEN department = 'Mens apparel' THEN total_value ELSE 0 END) AS Mens,
    SUM(CASE WHEN department = 'Tech' THEN total_value ELSE 0 END) AS Tech,
    SUM(CASE WHEN department = 'Shoes' THEN total_value ELSE 0 END) AS Shoes,
    SUM(CASE WHEN department = 'Womens apparel' THEN total_value ELSE 0 END) AS Womens
FROM 
    department_purchases_gender
GROUP BY 
    gender
ORDER BY 
    gender;
    
    
-- Customer segmentation of countries via departments
CREATE TABLE department_purchases_country AS 
SELECT 
    country,
    department,
    SUM(value_in_gbp) AS total_value
FROM 
    merged
GROUP BY 
    country, department
ORDER BY 
    country, department;
    
SELECT * FROM department_purchases_country;

SELECT 
    country,
    SUM(CASE WHEN department = 'Accessories' THEN total_value ELSE 0 END) AS Accessories,
    SUM(CASE WHEN department = 'Beauty' THEN total_value ELSE 0 END) AS Beauty,
    SUM(CASE WHEN department = 'Home' THEN total_value ELSE 0 END) AS Home,
    SUM(CASE WHEN department = 'Jewellery' THEN total_value ELSE 0 END) AS Jewellery,
    SUM(CASE WHEN department = 'Kids' THEN total_value ELSE 0 END) AS Kids,
    SUM(CASE WHEN department = 'Mens apparel' THEN total_value ELSE 0 END) AS Mens,
    SUM(CASE WHEN department = 'Tech' THEN total_value ELSE 0 END) AS Tech,
    SUM(CASE WHEN department = 'Shoes' THEN total_value ELSE 0 END) AS Shoes,
    SUM(CASE WHEN department = 'Womens apparel' THEN total_value ELSE 0 END) AS Womens
FROM 
    department_purchases_country
GROUP BY 
    country
ORDER BY 
    country;
    
    
SELECT 
    country,
    department,
    SUM(value_in_gbp) AS total_value
FROM 
    merged
GROUP BY 
    country, department
ORDER BY 
    country, department;
    
    
--

SELECT product_id, country, currency, value_in_gbp, COUNT(product_id) AS cp, SUM(value_in_gbp)
FROM merged
WHERE product_id = '115313232'
GROUP BY product_id, country, currency, value_in_gbp;


-- Best selling product in count
SELECT DISTINCT(product_id), category, COUNT(product_id) AS total_count, SUM(value_in_gbp) AS total_value_in_gbp
FROM merged
GROUP BY (product_id), category
ORDER BY total_count DESC
LIMIT 5;

-- Best selling product in count
SELECT DISTINCT(product_id), category, COUNT(product_id) AS total_count, value_in_gbp, SUM(value_in_gbp) AS total_value_in_gbp, currency, value_of_item
FROM merged
GROUP BY (product_id), category, value_in_gbp, currency, value_of_item
ORDER BY total_count DESC;
    

