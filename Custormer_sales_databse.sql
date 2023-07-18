-- Script to Create the view

create view customer_sales_database as
select customer.first_name, customer.last_name, customer.email, payment.amount, rental_date, film.rental_duration, film.replacement_cost, film.rating
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

select * from customer_sales_database

-- Next step is to download this data, and load up into a python enviroment, for this i would be using google collab, 
-- The aim is to answer these key business insights 
-- Top-Selling Films
-- Customer Segmentation
-- Peak Rental Times
-- Rental Duration vs. Film Rating
-- Replacement Cost vs. Profitability
-- Customer Lifetime Value (CLV)
-- Churn Analysis
-- Rentals by Rating
