-- This command ensures we are using the correct database context.
-- The error "Table 'sql_inventory.film' doesn't exist" indicates the database
-- client was looking for the table in a different database.
USE sakila;

-- This query analyzes rental data from the Sakila DB to provide a comprehensive
-- report on film performance, including revenue, rental counts, average duration,
-- and the top actor for each film, ranked by their total rental count.

-- We use a Common Table Expression (CTE) to pre-calculate key metrics
-- for each film, which improves readability and performance.
WITH FilmPerformance AS (
    -- First, calculate the total revenue, rental count, and average rental duration per film.
    SELECT
        f.film_id,
        f.title,
        f.rental_duration,
        c.name AS category_name,
        SUM(p.amount) AS total_revenue,
        COUNT(r.rental_id) AS rental_count,
        -- Corrected a potential issue with DATEDIFF() by using TIMESTAMPDIFF()
        -- for more robust compatibility across different SQL dialects.
        AVG(TIMESTAMPDIFF(DAY, r.rental_date, r.return_date)) AS avg_rental_days,
        -- Use a CASE statement for conditional aggregation to count rentals by year and month.
        SUM(CASE WHEN YEAR(r.rental_date) = 2005 AND MONTH(r.rental_date) = 5 THEN 1 ELSE 0 END) AS may_2005_rentals,
        SUM(CASE WHEN YEAR(r.rental_date) = 2005 AND MONTH(r.rental_date) = 6 THEN 1 ELSE 0 END) AS june_2005_rentals
    FROM
        film AS f
    -- Join to inventory to get the available copies of each film.
    INNER JOIN
        inventory AS i ON f.film_id = i.film_id
    -- Join to rental to get the rental transactions.
    INNER JOIN
        rental AS r ON i.inventory_id = r.inventory_id
    -- Join to payment to get the revenue for each rental.
    INNER JOIN
        payment AS p ON r.rental_id = p.rental_id
    -- Join to film_category and category to get the film's category.
    INNER JOIN
        film_category AS fc ON f.film_id = fc.film_id
    INNER JOIN
        category AS c ON fc.category_id = c.category_id
    GROUP BY
        f.film_id, f.title, f.rental_duration, c.name
),

-- Use another CTE to find the top actor for each film based on their
-- total number of rentals across all films. This demonstrates advanced subquery usage.
ActorPerformance AS (
    SELECT
        fa.film_id,
        a.actor_id,
        CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
        -- Use a window function (ROW_NUMBER) to rank actors for each film
        -- based on the total revenue of the films they appear in.
        ROW_NUMBER() OVER (PARTITION BY fa.film_id ORDER BY SUM(p.amount) DESC) AS revenue_rank
    FROM
        film_actor AS fa
    INNER JOIN
        actor AS a ON fa.actor_id = a.actor_id
    INNER JOIN
        film AS f ON fa.film_id = f.film_id
    INNER JOIN
        inventory AS i ON f.film_id = i.film_id
    INNER JOIN
        rental AS r ON i.inventory_id = r.inventory_id
    INNER JOIN
        payment AS p ON r.rental_id = p.rental_id
    GROUP BY
        fa.film_id, a.actor_id, a.first_name, a.last_name
)

-- The final SELECT statement brings everything together.
SELECT
    fp.title,
    fp.category_name,
    fp.total_revenue,
    fp.rental_count,
    fp.avg_rental_days,
    fp.may_2005_rentals,
    fp.june_2005_rentals,
    ap.actor_name AS top_actor_by_revenue,
    -- Rank films within their category by total revenue, demonstrating a window function.
    RANK() OVER (PARTITION BY fp.category_name ORDER BY fp.total_revenue DESC) AS category_revenue_rank
FROM
    FilmPerformance AS fp
-- Join with the ActorPerformance CTE to get the top actor for each film.
LEFT JOIN
    ActorPerformance AS ap ON fp.film_id = ap.film_id AND ap.revenue_rank = 1
-- The HAVING clause is applied after the aggregation in FilmPerformance CTE.
HAVING
    fp.rental_count > 10
ORDER BY
    fp.total_revenue DESC, category_name ASC;
