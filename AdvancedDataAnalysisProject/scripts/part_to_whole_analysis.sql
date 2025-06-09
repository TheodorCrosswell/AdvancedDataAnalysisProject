--Part to whole analysis

--which categories contribute the most to overall sales?

select
	distinct dp.product_category
	, sum(fs.sales_sales) over (partition by dp.product_category)
	as product_sales
	,concat(
		round(
			cast(
				cast(
					sum(fs.sales_sales) over (partition by dp.product_category) as float
				)
				/
				sum(fs.sales_sales) over() * 100
			as nvarchar)
			,2
		)
	,'%')
	as percentage_of_total_sales
	,sum(fs.sales_sales) over()
	as total_sales
from gold.fact_sales as fs
left join gold.dimension_products as dp
on dp.product_number = fs.product_number
order by product_sales desc