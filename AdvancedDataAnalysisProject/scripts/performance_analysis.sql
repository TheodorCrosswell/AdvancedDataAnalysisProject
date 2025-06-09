--Performance analysis

--Analyze the yearly performance of products by comparing each product's sales
--to both its average sales performance and the previous year's sales.

with cte1 as (
select 
	year(fs.sales_order_date) 
	as order_year
	,dp.product_name
	,sum(fs.sales_sales)
	as current_sales
from gold.fact_sales as fs
left join gold.dimension_products as dp
on fs.product_number = dp.product_number
where year(sales_order_date) is not null
group by dp.product_name, year(sales_order_date)
)

select
	order_year
	,product_name
	,current_sales
	--vs previous year
	,lag(current_sales) over(partition by product_name order by order_year)
	as previous_sales
	,current_sales - lag(current_sales) over(partition by product_name order by order_year)
	as current_sales_vs_previous_year
	,case
	when current_sales - lag(current_sales) over(partition by product_name order by order_year) > 0
	then 'Increased'
	when current_sales - lag(current_sales) over(partition by product_name order by order_year) < 0
	then 'Decreased'
	else 'Unchanged'
	end as performance_vs_previous_year
	--vs average
	,avg(current_sales) over(partition by product_name)
	as average_sales
	,current_sales - avg(current_sales) over(partition by product_name)
	as current_sales_vs_average_sales
	,case
	when current_sales - avg(current_sales) over(partition by product_name) > 0
	then 'Above'
	when current_sales - avg(current_sales) over(partition by product_name) < 0
	then 'Below'
	else 'Same'
	end as performance_vs_average
from cte1
order by product_name, order_year