--Create view - Customer report
/*
========================================
Create view - Customer Report
======================================== 

Purpose:
- This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details. 
2. Segments customers into categories (VIP, Regular, New) and age groups. 
3. Aggregates customer-level metrics:
   - total orders 
   - total sales 
   - total quantity purchased 
   - total products 
   - lifespan (in months) 
4. Calculates valuable KPIs:
   - recency (months since last order) 
   - average order value 
   - average monthly spend 
*/

create or alter view gold.report_customers as 
--This CTE gathers only the needed data columns from the dataset.
	with base_query as (
		select
			dc.customer_id
			,concat(
				customer_firstname
				,' '
				,customer_lastname
			)
			as customer_name
			,datediff(
				year
				, dc.customer_birthdate
				, getdate()
			)
			as customer_age
			,fs.product_number
			,fs.sales_order_number
			,fs.sales_order_date
			,fs.sales_price
			,fs.sales_quantity
			,fs.sales_sales
		from gold.fact_sales as fs
		left join gold.dimension_customers as dc
		on fs.customer_id = dc.customer_id
	)
	--this CTE performs the necessary aggregations
	, aggregations as (
		select
			customer_id
			,customer_name
			,customer_age
			,count(distinct sales_order_number)
			as customer_total_orders
			,sum(sales_sales)
			as customer_total_sales
			,sum(sales_quantity)
			as customer_total_quantity
			,count(distinct product_number)
			as customer_total_unique_products
			,datediff(
				month
				,min(sales_order_date)
				,max(sales_order_date)
			)
			as customer_lifespan_months
			,datediff(
				month
				,max(sales_order_date)
				,getdate()
			)
			as customer_months_since_last_order
		from base_query
		group by
			customer_id
			,customer_name
			,customer_age
	)
	--this CTE applies the final transformations
	, final_transformations as (
	select
		customer_id
		,customer_name
		,customer_age
		,case
			when customer_lifespan_months > 12 and customer_total_sales > 5000
				then 'VIP'
			when customer_lifespan_months > 12 and customer_total_sales <= 5000
				then 'Regular'
			else 'New'
		end as customer_spending_segment
		,case
			when customer_age < 18
				then 'Minor (<18)'
			when customer_age < 30
				then 'Young Adult (18-29)'
			when customer_age < 50
				then 'Middle-aged (30-49)'
			when customer_age < 70
				then 'Old (50-69)'
			when customer_age < 100
				then 'Very Old (70-99)'
			when customer_age >= 100
				then 'Extremely Old (100+)'
			else 'Unknown'
		end as customer_age_segment
		,customer_total_orders
		,customer_total_sales
		,customer_total_quantity
		,customer_total_unique_products
		,customer_lifespan_months
		,customer_months_since_last_order
		,case
			when customer_total_orders != 0
				then 
					customer_total_sales
					/
					customer_total_orders
			else 0
		end
		as customer_average_order_value
		,case
			when customer_lifespan_months != 0
				then 
					customer_total_sales
					/
					customer_lifespan_months
			else 0
		end
		as customer_average_monthly_spending
	from aggregations
	)
	select
		*
	from final_transformations
