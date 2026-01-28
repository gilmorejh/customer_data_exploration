--Total Revenue by male vs female
select gender, SUM(purchase_amount) as revenue
from customer
group by gender

--Customers that used discount code, but still spent more than the average purchase amount
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and purchase_amount > (select AVG(purchase_amount) from customer)

--Top 5 products by customer review
select item_purchased, ROUND(AVG (review_rating::numeric), 2) as "Average Product Rating"
from customer
group by item_purchased
order by AVG (review_rating) desc
limit 5;

--Compare average purchase by Standard and Express shipping
select shipping_type,
round(avg(purchase_amount), 2)
from customer
where shipping_type in ('Standard','Express')
group by shipping_type

--Compare average spend and total revenue between subscribers and non-subscribers
select subscription_status, 
count(customer_id) as total_customer, 
round(avg(purchase_amount), 2) as avg_spend, 
round(sum(purchase_amount), 2) as total_rev
from customer
group by subscription_status
order by total_rev, avg_spend desc;

--Top 5 products that have the highest percentage of purchases with discounts applied
select item_purchased,
round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*), 2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

--Segment customers into New, Returning, and Loyal based on their total number of previous purchases, and show the count of each segment
with customer_type as(
select customer_id, previous_purchases,
case 
	when previous_purchases = 1 then 'New'
	when previous_purchases BETWEEN 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
from customer
)
select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment

--Top 3 most purchased products within each category

with item_counts as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)

select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

--Likelihood of repeat customers (5 or more previous purchases) of being subscribers
select subscription_status, 
count(customer_id) as repeat_buyers
from customer
where previous_purchases >5
group by subscription_status

--Revenue contribution by age group
select age_group, 
sum(purchase_amount) as total_rev
from customer
group by age_group
order by total_rev desc
