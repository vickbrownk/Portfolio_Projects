-- Script to Create the view

create view data as
select payment.payment_id, customer.first_name, customer.last_name, customer.email, payment.amount, rental_date, film.rental_duration, film.replacement_cost, film.rating
from customer
inner join payment
on customer.customer_id = payment.customer_id
inner join  rental
on payment.rental_id = rental.rental_id
inner join inventory 
on rental.inventory_id = inventory.inventory_id
inner join film
on inventory.film_id = film.film_id


--



-- Next step is to download this data, and load up into a python enviroment, for this i would be using google collab, 
-- The aim is to answer these key business insights 
-- Top-Selling Films
-- Customer Segmentation for Loyalty Scheme Based on Previous Purchases
-- Peak Rental Times
-- Rental Duration vs. Film Rating
-- Replacement Cost vs. Profitability
-- Customer Lifetime Value (CLV)
-- Churn Analysis
-- Rentals by Rating


--5 highest selling films
select count(payment_id), title
from data
group by title
order by count(payment_id) desc
limit 5


---- Customer Segmentation for Loyalty Scheme Based on Previous Purchases
select email, 
case
	when count(payment_id) < 10 then 'Basic'
	when count(payment_id) > 30 then 'Premium'
	else 'standard'
end as loyalty_scheme_category 
from data
group by email


-- peak rental times
SELECT EXTRACT(HOUR FROM rental_date) AS rental_time, count(title) as Total_rental
FROM data
group by Rental_time
order by total_rental desc
limit 5

  
-- Rental Duration vs. Film Rating
select sum(rental_duration) as total_rental_hours, rating from data
group by rating
order by total_rental_hours desc


-- Replacement Cost vs. Profitability
SELECT
    sum(amount) as rental_income,
    replacement_cost,
    title,
    CASE
        WHEN sum(amount) > replacement_cost THEN (sum(amount) - replacement_cost)
        WHEN sum(amount) < replacement_cost THEN (sum(amount) - replacement_cost)
		
        ELSE NULL
    END AS profit,
	case
		when (sum(amount) - replacement_cost) > 0 then 'profit'
		when (sum(amount) - replacement_cost) < 0 then 'loss'
		else null
	end as profitablity 
FROM data
GROUP BY title, replacement_cost
order by profitablity desc



-- Customer Lifetime Value (CLV)
select 
	customer_id, 
	first_name, 
	last_name,
	email, 
	count(distinct(rental_id)) as total_purchases,
	sum(amount) as total_spent,
	(MAX(rental_date) - MIN(rental_date)) as customer_lifespan,
	(SUM(amount) / COUNT(DISTINCT rental_id)) * (COUNT(DISTINCT rental_id) / COUNT(DISTINCT rental_date)) * (extract(day from (MAX(rental_date) - MIN(rental_date)))) AS customer_lifetime_value
from data
GROUP BY
  	customer_id,
    first_name,
    last_name,
    email;


-- Churn Analysis
WITH monthly_rental_counts AS (
    SELECT
        customer_id,
        DATE_TRUNC('month', rental_date) AS rental_month,
        COUNT(DISTINCT rental_id) AS rental_count
    FROM
        customer_sales_database
    GROUP BY
        customer_id,
        DATE_TRUNC('month', rental_date)
)
SELECT
    rental_month,
    COUNT(DISTINCT customer_id) AS total_customers_at_beginning,
    COUNT(DISTINCT CASE WHEN rental_count = 0 THEN customer_id END) AS churned_customers,
    (COUNT(DISTINCT CASE WHEN rental_count = 0 THEN customer_id END) / COUNT(DISTINCT customer_id::FLOAT)) * 100 AS churn_rate
FROM
    monthly_rental_counts
GROUP BY
    rental_month
ORDER BY
    rental_month;


---- Rentals by Rating
select count(rental_id), rating from data
group by rating
order by count(rental_id) desc
