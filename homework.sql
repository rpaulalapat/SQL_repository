--- SQL Homework

USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`. 

SELECT 
    first_name, last_name
FROM
    actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`. 
SELECT 
    CONCAT(first_name, ' ', last_name) AS 'Actor Name'
FROM
    actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name LIKE 'Joe';

/*2b. Find all actors whose last name contain the letters `GEN`:*/
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    LOWER(last_name) LIKE '%gen%';

/*2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:*/
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    LOWER(last_name) LIKE '%li%'
ORDER BY last_name , first_name;

/*2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:*/
SELECT 
    country_id, country
FROM
    country
WHERE
    LOWER(country) IN ('afghanistan' , 'bangladesh', 'china');


/* 3a. Add a `middle_name` column to the table `actor`. Position it between `first_name` and `last_name`. */
ALTER table actor
    Add column middle_name VARCHAR(45) AFTER first_name;
    
/*3b. You realize that some of these actors have tremendously long last names. Change the data type of the `middle_name` column to `blobs`.*/
ALTER table actor
    MODIFY column middle_name BLOB;
    
/*3c. Now delete the `middle_name` column.*/

ALTER table actor
    DROP column middle_name;
    
/*4a. List the last names of actors, as well as how many actors have that last name.*/

SELECT 
    last_name, COUNT(*) AS count
FROM
    actor
GROUP BY last_name;

/*4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors*/

SELECT 
    last_name, COUNT(*) AS count
FROM
    actor
GROUP BY last_name
HAVING count > 1;

/*4c. Oh, no! The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.---*/

UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    (first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS');

/*Verify update*/

SELECT 
    *
FROM
    actor
WHERE
    last_name = 'WILLIAMS';

/* 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`. Otherwise, change the first name to `MUCHO GROUCHO`, as that is exactly what the actor will be with the grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO `MUCHO GROUCHO`, HOWEVER! (Hint: update the record using a unique identifier.)*/
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    actor_id = 172;

/*Verify update*/

SELECT 
    *
FROM
    actor
WHERE
    last_name = 'WILLIAMS';

/* 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it? */

/* find the schema if it is there*/
DESCRIBE address;

/* create a new table which is a copy if the other, commented out so as to not create a table */
/*CREATE TABLE new_address LIKE address;   */
  

SHOW CREATE TABLE address;

/* To copy the data across, if required, use */

SELECT 
    staff.first_name, staff.last_name, address.address
FROM
    staff
        LEFT JOIN
    address ON staff.address_id = address.address_id;

/* 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`. */

SELECT 
    staff.first_name, staff.last_name, SUM(payment.amount)
FROM
    staff
        JOIN
    payment ON staff.staff_id = payment.staff_id
        AND (MONTH(payment.payment_date) = 8
        AND YEAR(payment.payment_date) = 2005)
GROUP BY staff.staff_id;

/* 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join. */

SELECT 
    f.title, COUNT(fa.actor_id) AS 'Actor Count'
FROM
    film f
        JOIN
    film_actor fa ON f.film_id = fa.film_id
GROUP BY f.film_id;


/* 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system? */
SELECT 
    f.title, COUNT(inv.film_id)
FROM
    film f
        JOIN
    inventory inv ON f.film_id = inv.film_id
        AND (LOWER(f.title) = 'hunchback impossible');

/* 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:*/
SELECT 
    c.first_name,
    c.last_name,
    SUM(p.amount) AS 'Total Amount Paid'
FROM
    customer c
        JOIN
    payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

/* 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English. */

SELECT 
    title
FROM
    film
WHERE
    ((title LIKE 'K%') OR (title LIKE 'Q%'))
        AND film_id IN (SELECT 
            film_id
        FROM
            film
        WHERE
            language_id IN (SELECT 
                    language_id
                FROM
                    language
                WHERE
                    name = 'ENGLISH'));
   
/* 7b. Use subqueries to display all actors who appear in the film `Alone Trip`. */

SELECT 
    first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title LIKE 'Alone Trip'));
   
/* 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses 
of all Canadian customers. Use joins to retrieve this information.*/
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city.city_id
                FROM
                    city
                        JOIN
                    country ON city.country_id = country.country_id
                        AND (UPPER(country.country) = 'CANADA')));
   
/* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films. Assumption all movies rated G, PG and PG-13 are considered family movies*/

SELECT 
    title, rating
FROM
    film
WHERE
    rating IN ('G' , 'PG', 'PG-13');
 
 /* 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
Identify all movies categorized as famiy films. Assumption all movies rated G, PG and PG-13 are considered family movies*/

SELECT 
    title, rating
FROM
    film
WHERE
    rating IN ('G' , 'PG', 'PG-13');

/* 7e. Display the most frequently rented movies in descending order. */
SELECT 
    film.title, COUNT(rental.rental_id) AS 'rental_count'
FROM
    film
        JOIN
    inventory inv ON film.film_id = inv.film_id
        JOIN
    rental ON rental.inventory_id = inv.inventory_id
GROUP BY film.title
ORDER BY rental_count DESC;

/* 7f. Write a query to display how much business, in dollars, each store brought in.*/

SELECT 
    *
FROM
    sales_by_store s
ORDER BY s.total_sales;

/* 7g. Write a query to display for each store its store ID, city, and country. */
SELECT 
    st.store_id, city.city, country.country
FROM
    store st
        JOIN
    address adr ON st.address_id = adr.address_id
        JOIN
    city ON adr.city_id = city.city_id
        JOIN
    country ON city.country_id = country.country_id;
        
/* 7h. List the top five genres in gross revenue in descending order. 
(**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)*/
SELECT 
    *
FROM
    sales_by_film_category s
ORDER BY s.total_sales DESC
LIMIT 5;

SELECT 
    cat.name, SUM(pt.amount) AS 'Gross_revenue'
FROM
    category cat
        JOIN
    film_category f_cat ON cat.category_id = f_cat.category_id
        JOIN
    inventory inv ON f_cat.film_id = inv.film_id
        JOIN
    rental rt ON inv.inventory_id = rt.inventory_id
        JOIN
    payment pt ON pt.rental_id = rt.rental_id
GROUP BY cat.name
ORDER BY Gross_revenue DESC
LIMIT 5;

/* 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
If you haven't solved 7h, you can substitute another query to create a view.*/

CREATE OR REPLACE VIEW top_5_categories_by_revenue AS
    SELECT 
        cat.name, SUM(pt.amount) AS 'Gross_revenue'
    FROM
        category cat
            JOIN
        film_category f_cat ON cat.category_id = f_cat.category_id
            JOIN
        inventory inv ON f_cat.film_id = inv.film_id
            JOIN
        rental rt ON inv.inventory_id = rt.inventory_id
            JOIN
        payment pt ON pt.rental_id = rt.rental_id
    GROUP BY cat.name
    ORDER BY Gross_revenue DESC
    LIMIT 5;

/* 8b. How would you display the view that you created in 8a? */
SELECT 
    *
FROM
    sakila.top_5_categories_by_revenue;

/* 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it. */
DROP VIEW IF EXISTS top_5_categories_by_revenue;