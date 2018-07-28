USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.

-- DESCRIBE actor;

SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

SELECT CONCAT(first_name, " ", last_name) AS 'Actor Name' FROM actor;

-- Note: The names are already in upper case, if not UPPER can be used to convert them to upper case as stated below.
-- SELECT UPPER(CONCAT(first_name, " ", last_name)) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?

SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:

SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name and last_name.
-- Hint: you will need to specify the data type.

ALTER TABLE actor
	ADD COLUMN middle_name varchar(45) AFTER first_name;

-- SELECT * FROM actor;

-- 3b. You realize that some of these actors have tremendously long last names.
-- Change the data type of the middle_name column to blobs.

ALTER TABLE actor
	MODIFY COLUMN middle_name blob;

-- Describe actor;

-- 3c. Now delete the middle_name column.

ALTER TABLE actor
	DROP COLUMN middle_name;
    
-- describe actor;

-- 4a. List the last names of actors, as well as how many actors have that last name.

SELECT last_name, count(last_name) from actor group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

SELECT last_name, count(last_name) from actor group by last_name
having count(last_name) >= 2;

-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.

UPDATE actor
	SET first_name = 'HARPO'
		WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
        
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all! In a single query,
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
-- Otherwise, change the first name to MUCHO GROUCHO, as that is exactly what the actor will be with the grievous error.
-- BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER!
-- (Hint: update the record using a unique identifier.)

-- SET SQL_SAFE_UPDATES = 0;

UPDATE actor a
	SET a.first_name = 'GROUCHO'
		WHERE a.actor_id IN (select c.actor_id FROM (SELECT b.actor_id FROM actor b INNER JOIN actor a ON a.actor_id = b.actor_id WHERE b.first_name = 'HARPO' AND b.last_name = 'WILLIAMS') AS c);


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?

SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:

SELECT first_name, last_name, address from staff s
INNER JOIN address a ON a.address_id = s.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.

SELECT first_name, last_name, sum(amount) FROM staff s
INNER JOIN payment p ON s.staff_id = p.staff_id
WHERE month(payment_date) = 08 AND year(payment_date) = 2005
GROUP BY s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.

SELECT title, count(actor_id) AS 'Number of Actors' from film f
INNER JOIN film_actor a ON f.film_id = a.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select f.film_id, title, count(i.film_id) AS 'Number of Copies Available' from film f
INNER JOIN inventory i ON f.film_id = i.film_id
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:

SELECT first_name, last_name, sum(amount) AS 'Total Paid' from customer c
INNER JOIN payment p ON c.customer_id = p.customer_id
group by p.customer_id
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity.
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

-- select * from film;
-- select * from language;
SELECT title, language_id FROM film f
WHERE title LIKE 'K%'
OR title LIKE 'Q%'
AND language_id IN (SELECT language_id from language where name LIKE 'English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
-- select * from film where title = 'Alone Trip';
-- select * from actor;
-- Getting the results without subquery:
-- SELECT f.film_id, f.title, fa.film_id, fa.actor_id, a.actor_id, a.first_name, a.last_name from film f
-- INNER JOIN film_actor fa ON f.film_id = fa.film_id
-- INNER JOIN actor a ON fa.actor_id = a.actor_id
-- WHERE f.title = 'Alone Trip';

-- Getting same results with subquery:
SELECT first_name, last_name FROM actor a
WHERE actor_id IN
	(SELECT actor_id FROM film_actor fa
    WHERE film_id IN
		(SELECT film_id FROM film f
        WHERE f.title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.

SELECT c.first_name, c.last_name, c.email FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON ci.city_id = a.city_id
INNER JOIN country co ON co.country_id = ci.country_id
WHERE country = 'Canada';

-- checking if the above query is correct, it returned 5 rows.
-- select country_id from country where country = 'Canada'; --> country_id = 20

-- select city_id from city where country_id = 20; --> 179, 196, 300, 313, 383, 430, 565

-- select address_id from address where city_id IN (179, 196, 300, 313, 383, 430, 565); -->481, 468, 1, 3, 193, 415, 441
-- select first_name, last_name, email from customer where address_id IN (481, 468, 1, 3, 193, 415, 441); --> returns same five rows

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

-- select * from category; -->family category_id = 8
-- select film_id from film_category where category_id = 8; --> 69 rows returned

-- select * from film_text;
SELECT ft.title, ft.description, c.name AS 'film category' FROM film_text ft
INNER JOIN film_category fc ON ft.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 7e. Display the most frequently rented movies in descending order.
SELECT ft.title, count(ft.title) AS frequency FROM film_text ft
INNER JOIN inventory i ON ft.film_id = i.film_id
INNER JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY ft.title
ORDER BY frequency DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id AS 'Store ID', SUM(amount) AS 'Business in $' from payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN store s ON i.store_id = s.store_id
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS 'Store ID', c.city AS City, co.country AS Country
FROM store s
INNER JOIN address a ON s.address_id = a.address_id
INNER JOIN city c ON a.city_id = c.city_id
INNER JOIN country co ON c.country_id = co.country_id;

-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT SUM(amount) AS Gross, c.name AS Genre FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY Genre
ORDER BY Gross Desc LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view.
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE view GrossRevenueByGenre_View as (SELECT SUM(amount) AS Gross, c.name AS Genre FROM payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc ON i.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
GROUP BY Genre
ORDER BY Gross Desc LIMIT 5);

-- 8b. How would you display the view that you created in 8a?
Select * from GrossRevenueByGenre_View;

-- 8c. You find that you no longer need the view GrossRevenueByGenre_View. Write a query to delete it.
DROP view GrossRevenueByGenre_View;

