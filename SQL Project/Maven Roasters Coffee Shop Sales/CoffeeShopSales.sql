SELECT * FROM `first-a0.kopi.sales` limit 100;


-- Total Sales
SELECT 
  ROUND(SUM(unit_price * transaction_qty)) Total_Sales,
  EXTRACT(MONTH FROM transaction_date) Month
FROM `first-a0.kopi.sales` 
GROUP BY 2;


-- Total Sales KPI - MOM DIFFERENCE AND MOM GROWTH
WITH monthly_sales AS (
    SELECT 
        EXTRACT(MONTH FROM transaction_date) AS month,
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        `first-a0.kopi.sales`
    GROUP BY 
        month
)
SELECT 
    month,
    ROUND(total_sales, 0) AS total_sales,
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY month)) / LAG(total_sales, 1) OVER (ORDER BY month) * 100 AS mom_increase_percentage
FROM 
    monthly_sales
ORDER BY 
    month;



-- Total Orders
SELECT 
  COUNT(transaction_id) as Total_Orders,
  EXTRACT(MONTH FROM transaction_date) Month
FROM `first-a0.kopi.sales` 
GROUP BY 2;


-- Total Orders KPI - MOM DIFFERENCE AND MOM GROWTH
WITH monthly_orders AS (
    SELECT 
        EXTRACT(MONTH FROM transaction_date) AS month,
        COUNT(transaction_id) AS total_orders
    FROM 
        `first-a0.kopi.sales` 
    GROUP BY 
        month
)
SELECT 
    month,
    ROUND(total_orders, 0) AS total_orders,
    (total_orders - LAG(total_orders, 1) OVER (ORDER BY month)) / LAG(total_orders, 1) OVER (ORDER BY month) * 100 AS mom_increase_percentage
FROM 
    monthly_orders
ORDER BY 
    month;


-- Total Quantity Sold
SELECT 
  SUM(transaction_qty) as Total_Quantity_Sold,
  EXTRACT(MONTH FROM transaction_date) Month
FROM `first-a0.kopi.sales` 
GROUP BY 2;


-- Total Quantity SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
WITH monthly_sales AS (
    SELECT 
        EXTRACT(MONTH FROM transaction_date) AS month,
        SUM(transaction_qty) AS total_quantity_sold
    FROM 
        `first-a0.kopi.sales` 
    GROUP BY 
        month
)
SELECT 
    month,
    ROUND(total_quantity_sold, 0) AS total_quantity_sold,
    (total_quantity_sold - LAG(total_quantity_sold, 1) OVER (ORDER BY month)) / LAG(total_quantity_sold, 1) OVER (ORDER BY month) * 100 AS mom_increase_percentage
FROM 
    monthly_sales
ORDER BY 
    month;


-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
SELECT
    SUM(unit_price * transaction_qty) AS total_sales,
    SUM(transaction_qty) AS total_quantity_sold,
    COUNT(transaction_id) AS total_orders
FROM 
    `first-a0.kopi.sales` ;



SELECT 
    CONCAT(ROUND(SUM(unit_price * transaction_qty) / 1000, 1),'K') AS total_sales,
    CONCAT(ROUND(COUNT(transaction_id) / 1000, 1),'K') AS total_orders,
    CONCAT(ROUND(SUM(transaction_qty) / 1000, 1),'K') AS total_quantity_sold
FROM 
    `first-a0.kopi.sales`;





-- SALES TREND OVER PERIOD
SELECT AVG(total_sales) AS average_sales
FROM (
    SELECT 
        SUM(unit_price * transaction_qty) AS total_sales
    FROM 
        `first-a0.kopi.sales`
    GROUP BY 
        transaction_date
) AS internal_query;


-- DAILY SALES 
SELECT 
    EXTRACT(DAY FROM transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty), 1) AS total_sales
FROM 
    `first-a0.kopi.sales`
GROUP BY 
    day_of_month
ORDER BY 
    day_of_month;


-- COMPARING DAILY SALES WITH AVERAGE SALES 
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        EXTRACT(DAY FROM transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        `first-a0.kopi.sales`
    GROUP BY 
        day_of_month
) AS sales_data
ORDER BY 
    day_of_month;



-- SALES BY WEEKDAY / WEEKEND
SELECT 
    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 2) AS total_sales
FROM 
    `first-a0.kopi.sales`
GROUP BY 
    day_type
ORDER BY 
    day_type;


-- SALES BY STORE LOCATION
SELECT 
	store_location,
	SUM(unit_price * transaction_qty) as Total_Sales
FROM `first-a0.kopi.sales`
GROUP BY store_location
ORDER BY 	SUM(unit_price * transaction_qty) DESC;


-- SALES BY PRODUCT CATEGORY
SELECT 
	product_category,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `first-a0.kopi.sales` 
GROUP BY product_category
ORDER BY SUM(unit_price * transaction_qty) DESC;


-- SALES BY PRODUCTS (TOP 10)
SELECT 
	product_type,
	ROUND(SUM(unit_price * transaction_qty),1) as Total_Sales
FROM `first-a0.kopi.sales`
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- SALES BY DAY | HOUR
SELECT 
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales,
    SUM(transaction_qty) AS Total_Quantity,
    COUNT(*) AS Total_Orders
FROM 
    `first-a0.kopi.sales`
WHERE 
    EXTRACT(DAYOFWEEK FROM transaction_date) = 3 -- Tuesday 
    AND EXTRACT(HOUR FROM transaction_time) = 8 -- hour 8
    AND EXTRACT(MONTH FROM transaction_date) = 5; -- May



-- SALES FROM MONDAY TO SUNDAY 
SELECT 
    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 2 THEN 'Monday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 3 THEN 'Tuesday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 4 THEN 'Wednesday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 5 THEN 'Thursday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 6 THEN 'Friday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
FROM 
    `first-a0.kopi.sales`
GROUP BY 
    Day_of_Week
ORDER BY 
    CASE 
        WHEN Day_of_Week = 'Monday' THEN 1
        WHEN Day_of_Week = 'Tuesday' THEN 2
        WHEN Day_of_Week = 'Wednesday' THEN 3
        WHEN Day_of_Week = 'Thursday' THEN 4
        WHEN Day_of_Week = 'Friday' THEN 5
        WHEN Day_of_Week = 'Saturday' THEN 6
        ELSE 7
    END;


-- SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 2 THEN 'Monday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 3 THEN 'Tuesday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 4 THEN 'Wednesday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 5 THEN 'Thursday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 6 THEN 'Friday'
        WHEN EXTRACT(DAYOFWEEK FROM transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty), 0) AS Total_Sales
FROM 
    `first-a0.kopi.sales`
WHERE 
    EXTRACT(MONTH FROM transaction_date) = 5 -- May 
GROUP BY 
    Day_of_Week
ORDER BY 
    CASE 
        WHEN Day_of_Week = 'Monday' THEN 1
        WHEN Day_of_Week = 'Tuesday' THEN 2
        WHEN Day_of_Week = 'Wednesday' THEN 3
        WHEN Day_of_Week = 'Thursday' THEN 4
        WHEN Day_of_Week = 'Friday' THEN 5
        WHEN Day_of_Week = 'Saturday' THEN 6
        ELSE 7
    END;


-- SALES FOR ALL HOURS 
SELECT 
    EXTRACT(HOUR FROM transaction_time) AS Hour_of_Day,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    `first-a0.kopi.sales`
-- WHERE 
--     EXTRACT(MONTH FROM transaction_date) = 4 
GROUP BY 
    1
ORDER BY 
    1;
