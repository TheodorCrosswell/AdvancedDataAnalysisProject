--Cumulative analysis

--calculate the total sales per month
select 
	datetrunc(month,sales_order_date) as sales_order_month
	, sum(sales_sales) as current_sales
from gold.fact_sales 
where sales_order_date is not null 
group by datetrunc(month,sales_order_date) 
order by datetrunc(month,sales_order_date)

--calculate the running total of sales over time, resetting at the start of each year
with cte1 as(
select 
	datetrunc(month,sales_order_date) as sales_order_month
	, sum(sales_sales) as current_sales
from gold.fact_sales 
where sales_order_date is not null 
group by datetrunc(month,sales_order_date) 
)

select 
	sales_order_month
	,current_sales
	,sum(current_sales) over(partition by year(sales_order_month) order by sales_order_month asc rows between unbounded preceding and current row)
	as cumulative_current_sales
from cte1

--add the rolling average of the average price per order for 3 months
with cte1 as(
select 
	datetrunc(month,sales_order_date) as sales_order_month
	, sum(sales_sales) as current_sales
	, avg(sales_price) as average_price
from gold.fact_sales 
where sales_order_date is not null 
group by datetrunc(month,sales_order_date) 
)

select 
	sales_order_month
	,current_sales
	,sum(current_sales) over(partition by year(sales_order_month) order by sales_order_month asc rows between unbounded preceding and current row)
	as cumulative_current_sales
	,avg(average_price) over (order by sales_order_month asc rows between 2 preceding and current row)
	as rolling_average_price_3_months
from cte1