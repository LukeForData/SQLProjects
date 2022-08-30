-- Project Question - How much quarterly business has each Source generated for Block? Which sources are performing above or below their historical monthly benchmarks?

-- Final Column (Year, Month, Source, Generated Income)
-- CONDITIONS ?: Valid User (Same as 1st Question), Has 'Won Date' 

-- CTE Modify Gross Income Statement and add property_utm_source
--- Need to join three tables deal, deal_contact, and contact
---- modified Outer query with Case to Define Null as OTHER

WITH highestGross AS (
	
	SELECT
		d.deal_id,
		dc.contact_id,
		EXTRACT(YEAR FROM closed_won_date) AS Year, 
		TO_CHAR(closed_won_date, 'Month') AS Month,
		upper(trim(property_utm_source)) AS source,
		SUM(deal_value_usd) AS total_deals
	FROM deal d 
	FULL JOIN deal_contact dc
		ON d.deal_id = dc.deal_id
 	FULL JOIN contact c
		ON dc.contact_id = c.contact_id
	WHERE deal_value_usd IS NOT NULL
	--AND property_utm_source IS NOT NULL
	GROUP BY d.deal_id, dc.contact_id, Year, Month, source
	
)

SELECT 
	Year, Month, CASE WHEN source IS NULL THEN 'Other' ELSE source END, total_deals
FROM highestGross
ORDER BY total_deals DESC