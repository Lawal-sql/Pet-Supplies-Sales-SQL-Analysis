--missing values in category
select count(*)
from pet_supplies where category is null;--Answer is 25
--replace missing values with unknown
update pet_supplies
	set category = 'Unknown'
	where category is null;

--missing values in animal
select count(*)
from pet_supplies where animal is null;--Answer is 0

update pet_supplies
	set size = upper(size);
select count(distinct(size)) from pet_supplies;
--missing values in size
select count(*)
from pet_supplies where size is null;--Answer is 0

--missing values in price
select count(*)
from pet_supplies where price is null;--Answer is 150
--replace missing values with overal median price = 28.06
update pet_supplies
	set price = (select percentile_disc(0.5) within group (order by price)
				 from pet_supplies)
	where price is null;

--missing values in sales
select count(*)
from pet_supplies where sales is null;--Answer is 0

--missing values in rating
select count(*)
from pet_supplies where rating is null;--Answer is 150
--update missing values with 0
update pet_supplies
	set rating = 0
	where rating is null;

--missing values in repeat_purchase
select count(*)
from pet_supplies where repeat_purchase is null;--Answer is 0

select * from pet_supplies;

--Checking distint values in each categorical column
select count(distinct product_id)
from pet_supplies;

select distinct category
from pet_supplies;

select distinct animal
from pet_supplies;

select distinct size
from pet_supplies;

select distinct rating
from pet_supplies
order by rating asc;

select distinct repeat_purchase
from pet_supplies;

--Checking number of repeated and non-repeated purchases
select count(*) from pet_supplies
where repeat_purchase >0;

select count(*) from pet_supplies
where repeat_purchase =0;

--Create a temporary table for Repeat purchases
create temp table repeat_purchase_list as (select * from pet_supplies
											where repeat_purchase > 0
											);
select * from repeat_purchase_list;

--Repeated Purchase count by category
select category, count(*)
from repeat_purchase_list
group by category
order by count desc;

--Non-repeated Purchase count by category
select category, count(*)
from pet_supplies
group by category, repeat_purchase
having repeat_purchase = 0
order by count desc;

--Total Sales Recorded by Repeated Purchases
select sum(sales)
from repeat_purchase_list;

--Total Sales Recorded by Non-repeated Purchases
select sum(sales)
from pet_supplies
group by repeat_purchase
having repeat_purchase = 0;

--Viewing price and sales range within repeated and non-repeated groups
select case when repeat_purchase = 1 then 'Repeated Purchase' 
	else 'Non-repeated Purchase' end as repeat_purchase_categ,
	round(min(price), 2) as cheapest, round(avg(price), 2) as mean_price,
	percentile_disc(0.5) within group (order by price) as median_price, 
	round(max(price), 2) as most_expensive, round(sum(sales),2) as total_sales,
	round(avg(sales),2) as avg_sales
from pet_supplies
group by repeat_purchase;

--Drilling repeat_purchase sales down to category level
select case when repeat_purchase = 1 then category || ' ' || 'Repeated' 
	else category || ' ' || 'Not Repeated' end as repeat_purchase_categ,
	count(repeat_purchase), round(avg(sales), 2) as avg_sales 
from pet_supplies group by category, repeat_purchase order by avg_sales desc;