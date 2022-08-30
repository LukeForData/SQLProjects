-- 1st question 1.	Which month has the highest count of valid users created? 

-- final column (month, counting(valid users))
-- valid user (must not have @blockrenovation.com, userID not NULL, and first/last do not have test)

-- CTE to define valid users
-- JOIN contact, email, block_user on user_id
-- WHERE user_id NOT NULL
-- WHERE email NOT LIKE '%@blockrenovation.com'
-- WHERE first_name, last_name NOT LIKE ‘%test%’

-- NO aggregation, except counting in Outer Query
-- Need to take apart create_date fields into year, month


WITH validUsers AS (

	SELECT 
		DISTINCT(c.user_id), 
		EXTRACT(YEAR FROM create_date) AS Year, 
	--EXTRACT(MONTH FROM create_date) AS Month,
		TO_CHAR(create_date, 'Month') AS Month,
		first_name,
		last_name,
		hashed_email
	FROM contact c
	JOIN email e
		ON c.user_id = e.user_id
	JOIN block_user bu
		ON c.user_id = bu.user_id
	WHERE c.user_id IS NOT NULL
	AND NOT hashed_email ~* 'blockrenovation.com'
	AND NOT first_name ~* 'test'
	AND NOT last_name ~* 'test'
	
)

SELECT
	Year, Month, COUNT(user_id) AS total_valid_users
FROM validUsers
GROUP BY Year, Month
ORDER BY total_valid_users DESC