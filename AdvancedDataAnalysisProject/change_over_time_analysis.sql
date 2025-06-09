--Change over time analysis
--day-level aggregation
SELECT sales_order_date
	,sum(sales_sales) AS current_sales
	,count(DISTINCT customer_id) AS total_customers
	,sum(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE sales_order_date IS NOT NULL
GROUP BY sales_order_date
ORDER BY sales_order_date

--week-level aggregation
SELECT datepart(week, sales_order_date) AS sales_order_week
	,sum(sales_sales) AS current_sales
	,count(DISTINCT customer_id) AS total_customers
	,sum(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE sales_order_date IS NOT NULL
GROUP BY datepart(week, sales_order_date)
ORDER BY datepart(week, sales_order_date)

--month-level aggregation
SELECT datepart(month, sales_order_date) AS sales_order_month
	,sum(sales_sales) AS current_sales
	,count(DISTINCT customer_id) AS total_customers
	,sum(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE sales_order_date IS NOT NULL
GROUP BY datepart(month, sales_order_date)
ORDER BY datepart(month, sales_order_date)

--year-level aggregation
SELECT datepart(year, sales_order_date) AS sales_order_year
	,sum(sales_sales) AS current_sales
	,count(DISTINCT customer_id) AS total_customers
	,sum(sales_quantity) AS total_quantity
FROM gold.fact_sales
WHERE sales_order_date IS NOT NULL
GROUP BY datepart(year, sales_order_date)
ORDER BY datepart(year, sales_order_date)
--yearly change over time
WITH cte1 AS (
		SELECT datepart(year, sales_order_date) AS sales_order_year
			,sum(sales_sales) AS current_sales
			,count(DISTINCT customer_id) AS total_customers
			,sum(sales_quantity) AS total_quantity
		FROM gold.fact_sales
		WHERE sales_order_date IS NOT NULL
		GROUP BY datepart(year, sales_order_date)
		)

SELECT sales_order_year
	,current_sales
	,CONCAT (
		cast(round((
					cast(current_sales AS FLOAT) / lag(current_sales) OVER (
						ORDER BY sales_order_year ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS current_sales_difference
	,total_customers
	,CONCAT (
		cast(round((
					cast(total_customers AS FLOAT) / lag(total_customers) OVER (
						ORDER BY sales_order_year ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_customers_difference
	,total_quantity
	,CONCAT (
		cast(round((
					cast(total_quantity AS FLOAT) / lag(total_quantity) OVER (
						ORDER BY sales_order_year ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_quantity_difference
FROM cte1
ORDER BY sales_order_year
--monthly (all years) change over time
WITH cte1 AS (
		SELECT datepart(month, sales_order_date) AS sales_order_month
			,sum(sales_sales) AS current_sales
			,count(DISTINCT customer_id) AS total_customers
			,sum(sales_quantity) AS total_quantity
		FROM gold.fact_sales
		WHERE sales_order_date IS NOT NULL
		GROUP BY datepart(month, sales_order_date)
		)

SELECT sales_order_month
	,current_sales
	,CONCAT (
		cast(round((
					cast(current_sales AS FLOAT) / lag(current_sales) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS current_sales_difference
	,total_customers
	,CONCAT (
		cast(round((
					cast(total_customers AS FLOAT) / lag(total_customers) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_customers_difference
	,total_quantity
	,CONCAT (
		cast(round((
					cast(total_quantity AS FLOAT) / lag(total_quantity) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_quantity_difference
FROM cte1
ORDER BY sales_order_month


--monthly change over time
WITH cte1 AS (
		SELECT datetrunc(month, sales_order_date) AS sales_order_month
			,sum(sales_sales) AS current_sales
			,count(DISTINCT customer_id) AS total_customers
			,sum(sales_quantity) AS total_quantity
		FROM gold.fact_sales
		WHERE sales_order_date IS NOT NULL
		GROUP BY  datetrunc(month, sales_order_date)
		)

SELECT sales_order_month
	,current_sales
	,CONCAT (
		cast(round((
					cast(current_sales AS FLOAT) / lag(current_sales) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS current_sales_difference
	,total_customers
	,CONCAT (
		cast(round((
					cast(total_customers AS FLOAT) / lag(total_customers) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_customers_difference
	,total_quantity
	,CONCAT (
		cast(round((
					cast(total_quantity AS FLOAT) / lag(total_quantity) OVER (
						ORDER BY sales_order_month ASC
						) - 1
					) * 100, 2) AS NVARCHAR)
		,'%'
		) AS total_quantity_difference
FROM cte1
ORDER BY sales_order_month