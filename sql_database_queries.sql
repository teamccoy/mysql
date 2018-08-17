--1a. Display the first and last names of all actors from the table `actor`.
SELECT 
first_name,
last_name 
FROM actor;
--1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT 
first_name,
last_name,
UPPER(CONCAT(first_name, " " , last_name)) as "Actor Name"
FROM actor;
--2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
first_name,
last_name,
UPPER(CONCAT(first_name, " " , last_name)) as "Actor Name"
FROM actor
WHERE first_name = "Joe";
--2b. Find all actors whose last name contain the letters `GEN`:
SELECT 
first_name,
last_name,
UPPER(CONCAT(first_name, " " , last_name)) as "Actor Name"
FROM actor
WHERE last_name LIKE "%GEN%";
--2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT 
first_name,
last_name,
UPPER(CONCAT(first_name, " " , last_name)) as "Actor Name"
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name,first_name;
--2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT * 
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China")
--3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD description BLOB;

--3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

--4a. List the last names of actors, as well as how many actors have that last name.
SELECT
distinct last_name,
COUNT(last_name) as "Count of Same Last Name"
FROM actor
GROUP BY last_name;

--4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT
distinct last_name,
COUNT(last_name) as "Count of Same Last Name"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >2;
--4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
START TRANSACTION;
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO"
--4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
ROLLBACK;
--5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
DESCRIBE address;
--6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT
first_name,
last_name,
address
FROM staff 
JOIN address ON staff.address_id = address.address_id
--6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

SELECT
first_name,
last_name,
SUM(amount) as Total
FROM staff 
JOIN payment ON staff.staff_id = payment.staff_id
WHERE payment_date between "2005-08-01" AND "2005-08-30"
GROUP BY first_name,last_name;
--6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT
title,
COUNT(fa.actor_id) as "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON fa.film_id = f.film_id
INNER JOIN actor a
ON a.actor_id = fa.actor_id
GROUP BY title;
--6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT
title,
COUNT(title) as "Inventory Stock"
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
GROUP BY title;
--6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name
SELECT
last_name,
first_name,
SUM(amount) as "Total Payments"
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY last_name ASC, first_name
--7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

SELECT 
*
FROM film f
JOIN language l
ON f.language_id = l.language_id
WHERE title LIKE "K%" OR "Q%" AND name = "English"
--7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT 
first_name,
last_name
FROM film_actor fa
JOIN actor a
ON fa.actor_id = a.actor_id
WHERE film_id = (SELECT 
film_id
FROM film
WHERE title = "Alone Trip")
--7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT
first_name,
last_name,
email
FROM customer c
JOIN address a
ON c.address_id = a.address_id
JOIN city ci
ON ci.city_id = a.city_id
JOIN country co
ON co.country_id = ci.country_id
WHERE country = "Canada"
--7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select
f.title,
c.name
from film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category c
ON fc.category_id = c.category_id
where c.name = "Family"
--7e. Display the most frequently rented movies in descending order.
SELECT
title,
rental_date,
COUNT(title) as "Rental Frequency"
FROM film f
INNER JOIN inventory i
ON f.film_id = i.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
GROUP BY title, rental_date
ORDER BY COUNT(title) DESC
--7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
s.store_id,
SUM(amount) as "Total Sales"
FROM staff sf
JOIN payment p
ON sf.staff_id = p.staff_id
JOIN store s
ON s.store_id = sf.store_id
GROUP BY store_id
--7g. Write a query to display for each store its store ID, city, and country.
SELECT
s.store_id,
c.city,
co.country
FROM store s
JOIN address a
ON s.address_id =a.address_id
JOIN city c
ON c.city_id = a.city_id
JOIN country co
ON c.country_id = co.country_id
--7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: SELECT
c.name,
SUM(p.amount)
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY c.name DESC
LIMIT 5
--8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_genre_revenue AS
SELECT
c.name,
SUM(p.amount)
FROM category c
JOIN film_category fc
ON c.category_id = fc.category_id
JOIN inventory i
ON fc.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY c.name DESC
LIMIT 5
--8b. How would you display the view that you created in 8a?
SELECT *
FROM top_genre_revenue;
--8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genre_revenue;