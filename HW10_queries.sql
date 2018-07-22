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

