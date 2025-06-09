--Data segmentation analysis

-- Segment products into cost ranges and count how many products fall into each segment

--determining cost ranges by selecting all distinct cost values
--select distinct product_cost from gold.dimension_products

with cte1 as (
	select
		--product_name,
		case
		when product_cost < 100
		then 'Cheap (<100)'
		when product_cost < 250
		then 'Low (<250)'
		when product_cost < 500
		then 'Moderate (<500)'
		when product_cost < 1000
		then 'Expensive (<1000)'
		else 'Very expensive (>1000)'
		end as cost_range
	from gold.dimension_products
)

select 
	cost_range,
	count(*)
	as products_count
from cte1
group by cost_range

/* Group customers into three segments based on their spending behavior:
   - VIP: Customers with at least 12 months of history and spending more than 5,000.
   - Regular: Customers with at least 12 months of history but spending 5,000 or less.
   - New: Customers with a history of less than 12 months.
   And find the total number of customers by each group
*/
with cte1 as (
	select
		customer_id
		,datediff(
			month
			,first_value(sales_order_date) over (partition by customer_id order by sales_order_date asc)
			,last_value(sales_order_date) over (partition by customer_id order by sales_order_date asc)
		)
		as months_history
		,sum(sales_sales) over (partition by customer_id)
		as total_spending
	from gold.fact_sales
)
, cte2 as (
	select
		customer_id
		,case
		when months_history > 12 and total_spending > 5000
		then 'VIP'
		when months_history > 12 and total_spending <= 5000
		then 'Regular'
		else 'New'
		end as customer_status
	from cte1
)
select
	customer_status
	,count(distinct customer_id)
	as customers_count
from cte2
group by customer_status
order by customer_status