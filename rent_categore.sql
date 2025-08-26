-- Use the 'sakila' database to ensure we're querying the correct tables.
USE sakila;

-- This query counts the number of films rented per category for each year.
-- This is useful for identifying rental trends and popularity changes over time.
SELECT
    c.name AS category_name,
    YEAR(r.rental_date) AS rental_year,
    COUNT(r.rental_id) AS number_of_rentals
FROM
    category AS c
-- Join with film_category to link categories to films.
INNER JOIN
    film_category AS fc ON c.category_id = fc.category_id
-- Join with inventory to link films to their physical copies.
INNER JOIN
    inventory AS i ON fc.film_id = i.film_id
-- Join with rental to get the rental transaction data.
INNER JOIN
    rental AS r ON i.inventory_id = r.inventory_id
-- Group the results by category name and the year of the rental.
GROUP BY
    category_name,
    rental_year
-- Order the results to make them easy to read, with years ascending
-- and the number of rentals descending within each year.
ORDER BY
    category_name ASC,
    rental_year ASC,
    number_of_rentals DESC;

