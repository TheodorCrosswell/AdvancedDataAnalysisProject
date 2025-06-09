--Customer report
/*
========================================
Customer Report
========================================

Note: This query is messy, so I will make a new one that is more modular and maintainable. 

Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details. x
2. Segments customers into categories (VIP, Regular, New) and age groups. x x
3. Aggregates customer-level metrics:
   - total orders x
   - total sales x
   - total quantity purchased x
   - total products x
   - lifespan (in months) x
4. Calculates valuable KPIs:
   - recency (months since last order) x
   - average order value x
   - average monthly spend x
*/
with cte1 as (
	select
		dc.customer_id
		,dc.customer_firstname
		,dc.customer_lastname
		,datediff(
			year
			, dc.customer_birthdate
			, getdate()
		)
		as customer_age
		,fs.product_number
		,fs.sales_order_date
		,fs.sales_price
		,fs.sales_quantity
		,fs.sales_sales
		,sum(fs.sales_sales) over (partition by dc.customer_id)
		as customer_total_spending
		,count(sales_order_number) over (partition by dc.customer_id)
		as customer_total_orders
		,sum(fs.sales_sales) over (partition by dc.customer_id)
		as customer_total_sales
		,sum(fs.sales_quantity) over (partition by dc.customer_id)
		as customer_total_quantity
		,count(product_number) over (partition by dc.customer_id, fs.product_number)
		as customer_total_unique_products
		,datediff(
			month
			,first_value(fs.sales_order_date) over (partition by dc.customer_id order by fs.sales_order_date asc)
			,last_value(fs.sales_order_date) over (partition by dc.customer_id order by fs.sales_order_date asc)
		)
		as customer_lifespan
		,datediff(
			month
			,last_value(fs.sales_order_date) over (partition by dc.customer_id order by fs.sales_order_date asc)
			,getdate()
		)
		as customer_months_since_last_order
		,avg(sales_sales) over (partition by dc.customer_id)
		as customer_average_order_value
	from gold.fact_sales as fs
	left join gold.dimension_customers as dc
	on fs.customer_id = dc.customer_id
)
select
	customer_id
	,customer_firstname
	,customer_lastname
	,customer_age
	,product_number
	,sales_order_date
	,sales_price
	,sales_quantity
	,sales_sales
	,case
		when customer_lifespan > 12 and customer_total_spending > 5000
			then 'VIP'
		when customer_lifespan > 12 and customer_total_spending <= 5000
			then 'Regular'
		else 'New'
	end as customer_spending_segment
	,case
		when customer_age < 18
			then 'Minor'
		when customer_age < 30
			then 'Young Adult'
		when customer_age < 50
			then 'Middle-aged'
		when customer_age < 70
			then 'Old'
		when customer_age < 100
			then 'Very Old'
		when customer_age >= 100
			then 'Extremely Old'
		else 'Unknown'
	end as customer_age_segment
	,customer_total_spending
	,customer_total_orders
	,customer_total_sales
	,customer_total_quantity
	,customer_total_unique_products
	,customer_lifespan
	,customer_months_since_last_order
	,customer_average_order_value
	,customer_total_sales / nullif(customer_lifespan, 0)
	as customer_average_monthly_spending
from cte1
