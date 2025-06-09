--Create View - Product Report
/*
========================================
Create View - Product Report
========================================

Purpose:
- This report consolidates key product metrics and behaviors.

Highlights:
1. Gathers essential fields such as product name, category, subcategory, and cost.
2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
3. Aggregates product-level metrics:
   - total orders
   - total sales
   - total quantity sold
   - total customers (unique)
   - lifespan (in months)
4. Calculates valuable KPIs:
   - recency (months since last sale)
   - average order revenue (AOR)
   - average monthly revenue
========================================
 */

 create or alter view gold.report_products as
 --This CTE collects the basic data columns from the views.
	 with base_query as (
		select
			dp.product_number
			,dp.product_name
			,dp.product_category
			,dp.product_subcategory
			,dp.product_cost
			,fs.customer_id
			,fs.sales_order_number
			,fs.sales_order_date
			,fs.sales_price
			,fs.sales_quantity
			,fs.sales_sales
		from gold.fact_sales as fs
		left join
		gold.dimension_products as dp
		on fs.product_number = dp.product_number
	)
	--This CTE performs the necessary aggregations
	, aggregations as (
		select
			product_number
			,product_name
			,product_category
			,product_subcategory
			,product_cost
			,case 
				when sum(sales_sales) < 100000
					then 'Low-Performer'
				when sum(sales_sales) < 1000000
					then 'Mid-Range'
				when sum(sales_sales) >= 1000000
					then 'High-Performer'
			end
			as product_segment
			,count(distinct sales_order_number)
			as product_total_orders
			,sum(sales_sales)
			as product_total_sales
			,sum(sales_quantity)
			as product_total_quantity
			,count(distinct customer_id)
			as product_total_unique_customers
			,datediff(
				month
				,min(sales_order_date)
				,max(sales_order_date)
			)
			as product_lifespan_months
			,datediff(
				month
				,max(sales_order_date)
				,getdate()
			)
			as product_months_since_last_sale
		from base_query
		group by 
			product_number
			,product_name
			,product_category
			,product_subcategory
			,product_cost
		)
	--This CTE performs the final transformations
	, final_transformations as (
		select
			product_number
			,product_name
			,product_category
			,product_subcategory
			,product_cost
			,product_segment
			,product_total_orders
			,product_total_sales
			,product_total_quantity
			,product_total_unique_customers
			,product_lifespan_months
			,product_months_since_last_sale
			,case
				when product_total_orders != 0
					then 
						product_total_sales
						/
						product_total_orders
				else 0
			end
			as product_average_order_revenue
			,case
				when product_lifespan_months != 0
					then 
						product_total_sales
						/
						product_lifespan_months
				else 0
			end
			as product_average_monthly_revenue
		from aggregations
	)
	select
		*
	from final_transformations