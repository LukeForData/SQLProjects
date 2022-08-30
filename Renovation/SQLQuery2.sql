-- 2nd question	Which month brought in the highest gross deal value?

-- final column (month, max 'highest gross deal value' or show all)
-- no conditions, but deal_amount should not be null

-- CTE to sum the deal value
-- No JOIN (not matching against other tables)
-- Where deal_value NOT NULL
-- (Aggregation) GROUP BY year, month

-- Need to take apart closed_won_date fields into year, month

WITH highestGross AS (
	SELECT
		EXTRACT(YEAR FROM closed_won_date) AS Year, 
		TO_CHAR(closed_won_date, 'Month') AS Month,
		SUM(deal_value_usd) AS total_deals
	FROM deal
	WHERE deal_value_usd IS NOT NULL
	GROUP BY Year, Month
)

SELECT 
	Year, Month, total_deals
FROM highestGross
ORDER BY total_deals DESC