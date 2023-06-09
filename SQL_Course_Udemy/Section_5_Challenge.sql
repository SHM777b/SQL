/*
What are the emails of the customers who live California?
*/

SELECT district, email
FROM customer
INNER JOIN address 
ON customer.address_id = address.address_id
WHERE district ILIKE '%california%';

/*
Get a list of all the movies that Nick Wahlberg has been in
*/

SELECT title
FROM actor
INNER JOIN film_actor 
ON actor.actor_id = film_actor.actor_id
INNER JOIN film 
ON film_actor.film_id = film.film_id
WHERE first_name = 'Nick' AND last_name = 'Wahlberg'
;
