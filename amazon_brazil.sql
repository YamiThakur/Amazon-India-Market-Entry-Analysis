SET search_path TO amazon_brazil;

-- Analysis - I
-- #1 To simplify its financial reports, Amazon India needs to standardize payment values. 
-- Round the average payment values to integer (no decimal) for each payment type and display the results sorted in ascending order.

-- Output: payment_type, rounded_avg_payment
select 
	payment_type, 
	round(avg(payment_value)) as rounded_avg_paymnet
from payments
	group by 1
	order by 2

-- #2 To refine its payment strategy, Amazon India wants to know the distribution of orders by payment type.
-- Calculate the percentage of total orders for each payment type, rounded to one decimal place, 
-- and display them in descending order

-- Output: payment_type, percentage_orders
select 
	payment_type, 
	round(count(order_id)*100.0/(select count(order_id) from payments),1) as percentage_orders
from payments
	group by payment_type
	order by 2 desc	

-- #3 Amazon India seeks to create targeted promotions for products within specific price ranges.
-- Identify all products priced between 100 and 500 BRL that contain the word 'Smart' in their name.
-- Display these products, sorted by price in descending order.

-- Output: product_id, price
select 
	p.product_id,
	oi.price
from order_items oi
	join products p
	on oi.product_id = p.product_id
where (oi.price>100 and oi.price <500) and p.product_category_name like 'smart%'
order by 2 desc

--#4 To identify seasonal sales patterns, Amazon India needs to focus on the most successful months. 
-- Determine the top 3 months with the highest total sales value, rounded to the nearest integer.

-- Output: month, total_sales
select 
	extract(month from o.order_purchase_timestamp) as month_of_year,
	round(sum(p.payment_value),2) as total_sales
from orders o
	join payments p
	on o.order_id = p.order_id
group by 1
order by 2 desc
limit 3

--#5 Amazon India is interested in product categories with significant price variations.
-- Find categories where the difference between the maximum and minimum product prices is greater than 500 BRL.

-- Output: product_category_name, price_difference
select 
	p.product_category_name,
	(max(oi.price)-min(oi.price)) as price_difference
from products p
	join order_items oi
	on p.product_id = oi.product_id
group by 1
having (max(oi.price)-min(oi.price)) >500
order by 2 desc

--#6 To enhance the customer experience, Amazon India wants to find which payment types have the most consistent transaction amounts.
-- Identify the payment types with the least variance in transaction amounts, sorting by the smallest standard deviation first.

-- Output: payment_type, std_deviation
select 
	payment_type,
	round(stddev(payment_value),2) as std_deviation
from payments
group by 1
order by 2 asc

--#7 Amazon India wants to identify products that may have incomplete name in order to fix it from their end.
-- Retrieve the list of products where the product category name is missing or contains only a single character.

-- Output: product_id, product_category_name
select 
	product_id,
	product_category_name
from products
where product_category_name is null or length(product_category_name) = 1;


-- Analysis - II

-- #1 Amazon India wants to understand which payment types are most popular across different order value segments
-- (e.g., low, medium, high). 
-- Segment order values into three ranges: orders less than 200 BRL, between 200 and 1000 BRL, and over 1000 BRL. 
-- Calculate the count of each payment type within these ranges and display the results in descending order of count

-- Output: order_value_segment, payment_type, count

	select 
		case when payment_value <200
			 then '1 Less than 200 BRL'
			 when payment_value <1000
			 then '2 Between 200 and 1000 BRL'
			 when payment_value >1000
			 then '3 Over 1000 BRL'
		end as order_value_segment,
		payment_type,
		count(payment_value)
	from payments p
	group by 1,2
	order by 2,1 asc

-- #2 Amazon India wants to analyse the price range and average price for each product category.
-- Calculate the minimum, maximum, and average price for each category, and list them in descending order by the average price.

-- Output: product_category_name, min_price, max_price, avg_price
select
	p.product_category_name,
	min(oi.price) as minimum_price,
	max(oi.price) as maximum_price,
	round(avg(oi.price),2) as average_price
from order_items oi
join products p
on oi.product_id = p.product_id
group by p.product_category_name
order by 4 desc

--#3 Amazon India wants to identify the customers who have placed multiple orders over time.
-- Find all customers with more than one order, and display their customer unique IDs along with the total number of orders they have placed.

-- Output: customer_unique_id, total_orders
select 
	c.customer_id,
	count(o.order_id)
from customers c
join orders o
on c.customer_id = o.customer_id
group by 1
having count(o.order_id)>1
order by 2 desc

--#4 Amazon India wants to categorize customers into different types 
-- ('New – order qty. = 1' ;  'Returning' –order qty. 2 to 4;  'Loyal' – order qty. >4) based on their purchase history. 
-- Use a temporary table to define these categories and join it with the customers table to update and display the customer types.

-- Output: customer_unique_id, customer_type
with temp_table as
	(
		select customer_id,
			   count(order_id) as no_of_purchases,
			   case when count(order_id) = 1
			   then 'New'
			   when count(order_id)<4
			   then 'Returning'
			   when count(order_id)>4
			   then 'Loyal'
			   end as type_of_customer
		from orders	
		group by customer_id
	)
select c.customer_unique_id, t.type_of_customer
from customers c
join temp_table t
on c.customer_id = t.customer_id

-- #5 Amazon India wants to know which product categories generate the most revenue. 
-- Use joins between the tables to calculate the total revenue for each product category. 
-- Display the top 5 categories.

-- Output: product_category_name, total_revenue
select 
	product_category_name,
	sum(payment_value) as total_revenue
from products p
join order_items oi
on p.product_id = oi.product_id
join payments ps
on oi.order_id = ps.order_id
group by 1
order by 2 desc
limit 5

-- Analysis - III
-- #1 The marketing team wants to compare the total sales between different seasons. 
-- Use a subquery to calculate total sales for each season (Spring, Summer, Autumn, Winter) 
-- based on order purchase dates, and display the results. 
-- Spring is in the months of March, April and May. 
-- Summer is from June to August and 
-- Autumn is between September and November and 
-- rest months are Winter. 

-- Output: season, total_sales
select
	case 
		when extract(month from o.order_purchase_timestamp) between 2 and 6
		then 'Spring'
		when extract(month from o.order_purchase_timestamp) between 5 and 9
		then 'Summer'
		when extract(month from o.order_purchase_timestamp) between 8 and 12
		then 'Autumn'
		else 'Winter'
	end as season,
	sum(payment_value) as total_sales
from payments p
join orders o
on p.order_id = o.order_id
group by 1

-- #2 The inventory team is interested in identifying products that have sales volumes above the overall average.
-- Write a query that uses a subquery to filter products with a total quantity sold above the average quantity.

-- Output: product_id, total_quantity_sold

with cte as
( select product_id, count(order_id) as total_quantity_sold
from order_items
group by product_id
)

select product_id, total_quantity_sold
from cte
where total_quantity_sold> (select round(avg(total_quantity_sold)) from cte)
order by total_quantity_sold desc


-- #3 To understand seasonal sales patterns, the finance team is analysing the monthly revenue trends over the past year (year 2018). 
-- Run a query to calculate total revenue generated each month and identify periods of peak and low sales. 
-- Export the data to Excel and create a graph to visually represent revenue changes across the months. 

-- Output: month, total_revenue

select
extract (month from o.order_purchase_timestamp) as month, sum(p.payment_value) as revenue
from orders o
join payments p
on o.order_id = p.order_id
group by 1
order by 1 asc

-- Excel chart created.

-- #4 A loyalty program is being designed  for Amazon India. 
-- Create a segmentation based on purchase frequency: ‘Occasional’ for customers with 1-2 orders, 
-- ‘Regular’ for 3-5 orders, and ‘Loyal’ for more than 5 orders. 
-- Use a CTE to classify customers and their count and generate a chart in Excel to show the proportion of each segment.

-- Output: customer_type, count

with cte as
(
	select
		customer_id,
		count(order_id) as purchase_frequency,
		case
			 when count(order_id)<=2
			 then 'Occasional'
			 when count(order_id)<=5
			 then 'Regular'
			 when count(order_id)>6
			 then 'Loyal'
		end as segment
		from orders
	group by customer_id
	order by 1 desc
)

select segment, count(customer_id) as number_of_customers
	from cte
group by segment


-- #5 Amazon wants to identify high-value customers to target for an exclusive rewards program. 
-- You are required to rank customers based on their average order value (avg_order_value) to find the top 20 customers.

-- Output: **customer_id, avg_order_value, and customer_rank**

select 
	o.customer_id, 
	round(avg(p.payment_value),2) as average_order_value,
	dense_rank() over(order by avg(p.payment_value) desc) as customer_rank
from orders o
join payments p
on o.order_id = p.order_id
group by o.customer_id
order by 2 desc
limit 20


-- #6 Amazon wants to analyze sales growth trends for its key products over their lifecycle.
-- Calculate monthly cumulative sales for each product from the date of its first sale.
-- Use a recursive CTE to compute the cumulative sales (total_sales) for each product month by month.

-- Output: product_id, sale_month, and total_sales

with recursive product_lifecycles as (
    select 
        oi.product_id,
        DATE_TRUNC('month', min(o.order_purchase_timestamp)) as sale_month,
        DATE_TRUNC('month', max(o.order_purchase_timestamp)) as max_month
    from order_items oi
    join orders o on oi.order_id = o.order_id
    group by oi.product_id
		
		union all
		
    select 
        product_id,
        (sale_month + INTERVAL '1 month')::timestamp as sale_month,
        max_month
    from product_lifecycles
    where sale_month < max_month
		),
	monthly_actual_sales as (

    select 
        oi.product_id,
        DATE_TRUNC('month', o.order_purchase_timestamp) as sale_month,
        sum(oi.price) as monthly_revenue
    from order_items oi
    join orders o on oi.order_id = o.order_id
    group by oi.product_id, DATE_TRUNC('month', o.order_purchase_timestamp)
	)

select 
    pl.product_id,
    TO_CHAR(pl.sale_month, 'YYYY-MM') as sale_month,
    sum(coalesce(mas.monthly_revenue, 0)) over (
        partition by pl.product_id 
        order by pl.sale_month
    ) as total_sales
from product_lifecycles pl
left join monthly_actual_sales mas 
    on pl.product_id = mas.product_id 
   and pl.sale_month = mas.sale_month
order by pl.product_id, pl.sale_month


-- #7 To understand how different payment methods affect monthly sales growth,
-- Amazon wants to compute the total sales for each payment method and 
-- calculate the month-over-month growth rate for the past year (year 2018). 
-- Write query to first calculate total monthly sales for each payment method, then compute the percentage change from the previous month.

-- Output: payment_type, sale_month, monthly_total, monthly_change.

With 
cte as 
(
	select 
		p.payment_type as type_of_payment,
		extract(month from o.order_purchase_timestamp) as sale_month,
		sum(p.payment_value) as monthly_total
	from payments p
	join orders o
	on p.order_id = o.order_id
	group by p.payment_type, extract(month from o.order_purchase_timestamp)
	order by 1
)
select 
	type_of_payment,
	sale_month,
	monthly_total,
	round((monthly_total-lag(monthly_total) over(partition by type_of_payment order by sale_month))/
	nullif(lag(monthly_total) over(partition by type_of_payment order by sale_month),0)*100,2) as monthly_change
	
from cte
	order by 1,2
