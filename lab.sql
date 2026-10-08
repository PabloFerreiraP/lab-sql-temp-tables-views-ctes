-- Step 1: Create a View that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
USE sakila;

DROP VIEW customer_rental_summary;

CREATE VIEW customer_rental_summary AS 
SELECT c.customer_id, 
	CONCAT(first_name," ",c.last_name) as customer_name,
	c.email,
	COUNT(*) as rental_count
FROM 
	customer as c
	JOIN rental as r
    ON c.customer_id = r.customer_id
GROUP BY c.customer_id
ORDER BY rental_count DESC;

-- Step 2: Create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

DROP TEMPORARY TABLE customer_payment_summary;

CREATE TEMPORARY TABLE customer_payment_summary AS (
	SELECT 	
		crs.customer_id,
		SUM(p.amount) as total_paid
	FROM 
		customer_rental_summary as crs
		JOIN rental as r ON crs.customer_id = r.customer_id
        JOIN payment as p ON r.rental_id = p.rental_id
	GROUP BY 
		crs.customer_id
);
        
-- Step 3: Create a CTE and the Customer Summary Report that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary_cte AS (
	SELECT 
		crs.customer_id,
        crs.email,
        crs.rental_count,
        cps.total_paid
	FROM 
		customer_rental_summary as crs
        JOIN customer_payment_summary as cps ON crs.customer_id = cps.customer_id
)

SELECT 
	*,
    total_paid/rental_count as average_payment_per_rental
FROM
	customer_summary_cte
ORDER BY rental_count DESC;
