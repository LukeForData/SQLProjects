-- 3rd Question - Which percentage of 'closed won' deals does each city account for? 

-- Final Column (City, percentage_of_total_closed_deals)
-- CONDITIONS: Valid User (Same as 1st Question), Has 'Won Date' 

-- CTE from 1st Question for Valid Users
---- might need to add property_city and remove dates
---- remove DISTINCT on user_id to show multiple deals completed
---- Need to combine property_city for upper or lower case

-- NESTed CTE for Counting Total Deals Won

---- SELECT property_city, COUNT(closed_won_date)
---- Nested CTE JOIN first cte table, deal_contact, and deal
---- Where closed_won_date IS NOT NULL
---- (Aggregation) GROUP BY is needed

-- Can possibly take out truncating dates/timestamps

WITH validUsers AS (
	
	SELECT 
		c.user_id, 
		contact_id,
		upper(trim(property_city)) as city,
		first_name,
		last_name,
		hashed_email
	FROM contact c
	JOIN email e
		ON c.user_id = e.user_id
	JOIN block_user bu
		ON c.user_id = bu.user_id
	WHERE c.user_id IS NOT NULL
	AND property_city IS NOT NULL
	AND NOT hashed_email ~* 'blockrenovation.com'
	AND NOT first_name ~* 'test'
	AND NOT last_name ~* 'test'

),

CountOfClosedWon AS (

	SELECT
		city,
		COUNT(c.contact_id) as count_totals
	FROM validUsers c
	FULL JOIN deal_contact dc
		ON c.contact_id = dc.contact_id
	FULL JOIN deal d
		ON c.contact_id = d.deal_id
	WHERE dc.deal_id IS NOT NULL
	GROUP BY 1

)

select 
	city,
	count_totals,
	CAST(count_totals * 100 / SUM(count_totals) OVER () as Decimal(10,2)) as Perc
from CountOfClosedWon
order by count_totals desc