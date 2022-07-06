--- Data for this project was exported to xlsx and imported to Tableau for this project:
--- https://public.tableau.com/app/profile/luke.haakenson/viz/SafeBuyer-AustinHousingMarket/Story1
------------------------------------------------------
--- 

SELECT *
FROM Austin_Crime_Reports

SELECT *
FROM Austin_Housing_Commute

SELECT *
FROM Austin_Housing_Inner



--1.  Standardize Date Format
------------------------------------------------------

--- Inner

SELECT latest_saledate, CONVERT(Date, latest_saledate) AS latest_saledate_converted
FROM Austin_Housing_Inner

UPDATE Austin_Housing_Inner
SET latest_saledate = CONVERT(Date,latest_saledate)

ALTER TABLE Austin_Housing_Inner
ADD latest_saledate_converted Date; <--New Column

UPDATE Austin_Housing_Inner
SET latest_saledate_converted = CONVERT(Date,latest_saledate) <-- Add to new column

SELECT latest_saledate_converted
FROM Austin_Housing_Inner

--- Commute

ALTER TABLE Austin_Housing_Commute
ADD latest_saledate_converted Date; <--New Column

UPDATE Austin_Housing_Commute
SET latest_saledate_converted = CONVERT(Date,latest_saledate) <-- Add to new column

SELECT latest_saledate_converted
FROM Austin_Housing_Commute

--- Crime

SELECT (occurred date), CONVERT(Date, latest_saledate) AS latest_saledate_converted
FROM Austin_Housing_Inner


------------------------------------------------------
-- 2. Check if Property Address Data is Empty (Populate if necessary)

SELECT *
FROM Austin_Housing_Commute
WHERE streetAddress is null

SELECT *
FROM Austin_Housing_Inner
WHERE streetAddress is null

SELECT *
FROM Austin_Crime_Reports
WHERE Address is null

SELECT a.IncidentNumber, a.Address, b.IncidentNumber, b.Address, 
		ISNULL(a.Address,b.Address)
FROM Austin_Crime_Reports a
JOIN Austin_Crime_Reports b
	ON a.IncidentNumber = b.IncidentNumber
WHERE a.Address is null

UPDATE a
SET Address = ISNULL(a.Address,b.Address)
FROM Austin_Crime_Reports a
JOIN Austin_Crime_Reports b
	ON a.IncidentNumber = b.IncidentNumber
WHERE a.Address is null


------------------------------------------------------
-- 3. Practice Adding City to StreetAddress Data Column

-- Austin Housing is separated, but Austin Crime is not
-- Austin Crime only has a street address, no city
-- (Practice Austin Housing to update streetAddress with City from separate column

SELECT streetAddress
FROM Austin_Housing_Inner <--View

SELECT CONCAT(streetaddress, ', ', UPPER(LEFT(city, 1)), 
                             LOWER(SUBSTRING(city, 2, LEN(CITY))),'-',zipcode) as full_address 
FROM Austin_Housing_Inner;

SELECT CONCAT(streetaddress, ', ', UPPER(LEFT(city, 1)), 
                             LOWER(SUBSTRING(city, 2, LEN(CITY))),'-',zipcode) as full_address 
FROM Austin_Housing_Commute;

-- Update

ALTER TABLE Austin_Housing_Inner
ADD full_address NVARCHAR(255);

ALTER TABLE Austin_Housing_Commute
ADD full_address NVARCHAR(255);

UPDATE Austin_Housing_Inner
SET full_address = CONCAT(streetaddress, ', ', UPPER(LEFT(city, 1)), 
                             LOWER(SUBSTRING(city, 2, LEN(CITY))),'-',zipcode)

UPDATE Austin_Housing_Commute
SET full_address = CONCAT(streetaddress, ', ', UPPER(LEFT(city, 1)), 
                             LOWER(SUBSTRING(city, 2, LEN(CITY))),'-',zipcode)


------------------------------------------------------
-- 4. Change Y and N to Yes and No respectively in "FamilyViolence" field

SELECT DISTINCT(FamilyViolence), COUNT(FamilyViolence)
FROM Austin_Crime_Reports
GROUP BY FamilyViolence
ORDER BY 2 <-- Check the count for all these


SELECT FamilyViolence,
	   CASE WHEN FamilyViolence = 'Y' THEN 'Yes'
			WHEN FamilyViolence = 'N' THEN 'No'
			ELSE FamilyViolence
			END
FROM Austin_Crime_Reports <--Test a view

UPDATE Austin_Crime_Reports
SET FamilyViolence = CASE WHEN FamilyViolence = 'Y' THEN 'Yes'
						WHEN FamilyViolence = 'N' THEN 'No'
						ELSE FamilyViolence
						END

--
SELECT DISTINCT(ClearanceStatus), COUNT(ClearanceStatus)
FROM Austin_Crime_Reports
GROUP BY ClearanceStatus
ORDER BY 2

------------------------------------------------------
-- 5. Remove Duplicates if any

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY zpid,
					streetAddress,
					latestPrice,
					latest_saledate
					ORDER BY
						city
						) row_num

FROM Austin_Housing_Commute
ORDER BY zpid <--Test with a view
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY zpid,
					streetAddress,
					latestPrice,
					latest_saledate
					ORDER BY
						city
						) row_num

FROM Austin_Housing_Commute
)
SELECT *
--DELETE
FROM RowNumCTE
WHERE row_num > 1


------------------------------------------------------
-- 6. Delete Unused Columns

ALTER TABLE Austin_Housing_Commute
DROP COLUMN numOfBedrooms, numOfStories

ALTER TABLE Austin_Housing_Inner
DROP COLUMN numOfBedrooms, numOfStories

ALTER TABLE Austin_Crime_Reports
DROP COLUMN HighestOffenseCode, CensusTract, ClearanceStatus,CategoryDescription

ALTER TABLE Austin_Crime_Reports
DROP COLUMN OccurredDate, ReportDate, ClearanceDate

ALTER TABLE Austin_Crime_Reports
DROP COLUMN c_ReportDate, c_ClearanceDate

ALTER TABLE Austin_Crime_Reports
DROP COLUMN OccurredDateTime, OccurredTime, ReportDateTime, ReportTime

------------------------------------------------------
-- 7. Total Homes for Sale, AvgPrice, MedianPrice

DECLARE @c BIGINT = (SELECT COUNT(*) FROM Austin_Housing_Inner);
SELECT AVG(1.0 * latestPrice) AS MeanPrice
		FROM (
			SELECT latestPrice FROM Austin_Housing_Inner
			ORDER BY latestPrice
			OFFSET (@c - 1) / 2 ROWS
			FETCH NEXT 1 + (1 - @c % 2) ROWS ONLY
			) AS MeanPrice

SELECT latest_saleyear, COUNT(DISTINCT(zpid)) AS HomesSold, AVG(latestPrice) as AvgPrice
FROM Austin_Housing_Inner
GROUP BY latest_saleyear
ORDER BY latest_saleyear

------------------------------------------------------
-- 8. Need to determine which zip codes to remove between Inner and Commuter
-- InnerCity will be 78701, 78702, 78703, 78704, 78705, 78712, 78722, 78731, 78741, 78746, 78751, 78752, 78756, 78757
-- Commute (Suburbs) will be All Others

SELECT *
FROM Austin_Housing_Inner
WHERE NOT zipcode IN (78701, 78702, 78703, 78704, 78705, 78712, 78722, 78731, 78741, 78746, 78751, 78752, 78756, 78757)

DELETE
FROM Austin_Housing_Inner
WHERE NOT zipcode IN (78701, 78702, 78703, 78704, 78705, 78712, 78722, 78731, 78741, 78746, 78751, 78752, 78756, 78757)

DELETE
FROM Austin_Housing_Commute
WHERE zipcode IN (78701, 78702, 78703, 78704, 78705, 78712, 78722, 78731, 78741, 78746, 78751, 78752, 78756, 78757)

SELECT *
FROM Austin_Housing_Inner

SELECT *
FROM Austin_Housing_Commute

------------------------------------------------------
-- 9. Find Houses Sold and Avg Prices by ZipCode and City per year (Inner and Commute)

SELECT latest_saleyear, COUNT(DISTINCT(zpid)) AS HomesSold, AVG(latestPrice) as AvgPrice
FROM Austin_Housing_Inner
GROUP BY latest_saleyear
ORDER BY latest_saleyear

SELECT latest_saleyear, COUNT(DISTINCT(zpid)) AS HomesSold, AVG(latestPrice) as AvgPrice
FROM Austin_Housing_Commute
GROUP BY latest_saleyear
ORDER BY latest_saleyear

SELECT latest_saleyear, zipcode, COUNT(DISTINCT(zpid)) AS HomesSold, AVG(latestPrice) as AvgPrice
FROM Austin_Housing_Commute
GROUP BY latest_saleyear, zipcode
ORDER BY latest_saleyear  <---Counts and Avg by Zip

SELECT latest_saleyear, zipcode, COUNT(DISTINCT(zpid)) AS HomesSold, AVG(latestPrice) as AvgPrice
FROM Austin_Housing_Inner
GROUP BY latest_saleyear, zipcode
ORDER BY latest_saleyear <---Counts and Avg by Zip

------------------------------------------------------
-- 11. Clean up Austin Crime Reports

-- Fix Occurred Date to Extract Year from data into new Year Column

ALTER TABLE Austin_Crime_Reports
ADD c_ReportDate Date, c_OccurredDate Date, c_ClearanceDate Date;

UPDATE Austin_Crime_Reports
SET c_ReportDate = CONVERT(Date,ReportDate)
UPDATE Austin_Crime_Reports
SET c_OccurredDate = CONVERT(Date,OccurredDate)
UPDATE Austin_Crime_Reports
SET c_ClearanceDate = CONVERT(Date,ClearanceDate)

--

SELECT DATEPART(yyyy, c_OccurredDate)
FROM Austin_Crime_Reports

ALTER TABLE Austin_Crime_Reports
ADD OccurredYear Int;

UPDATE Austin_Crime_Reports
SET OccurredYear = DATEPART(yyyy, c_OccurredDate)

--

SELECT *
FROM Austin_Crime_Reports

-- (delete unused years before 2018)

DELETE
FROM Austin_Crime_Reports
WHERE NOT OccurredYear IN (2018,2019,2020,2021,2022)

-- Austin Crime Totals

SELECT OccurredYear, COUNT(DISTINCT(IncidentNumber)) AS TotalCrimes
FROM Austin_Crime_Reports
WHERE OccurredYear IN (2018,2019,2020,2021,2022)
GROUP BY OccurredYear
ORDER BY OccurredYear

-- By Zip

SELECT OccurredYear, ZipCode, COUNT(DISTINCT(IncidentNumber)) AS TotalCrimes
FROM Austin_Crime_Reports
WHERE OccurredYear IN (2018,2019,2020,2021,2022)
GROUP BY OccurredYear, ZipCode
ORDER BY OccurredYear

SELECT OccurredYear, ZipCode, COUNT(DISTINCT(IncidentNumber)) AS TotalCrimes
FROM Austin_Crime_Reports
WHERE OccurredYear IN (2018,2019,2020,2021,2022) AND ZipCode Is Not Null
GROUP BY OccurredYear, ZipCode
ORDER BY OccurredYear

------------------------------------------------------
-- 10. Join Austin Housing with Crimes Reported by Zip Code and Dates, Last Column is Total Crimes in Area that Year

--Inner City

SELECT h.zpid, h.zipcode, h.latest_saleyear, h.latestPrice, COUNT(c.IncidentNumber) AS CrimeOccurrencesAtZip
FROM Austin_Housing_Inner h
INNER JOIN Austin_Crime_Reports c
	ON h.zipcode = c.zipcode
	AND h.latest_saleyear = c.OccurredYear
GROUP BY h.zpid, h.zipcode, h.latest_saleyear, h.latestPrice
ORDER BY h.zpid, h.zipcode, h.latest_saleyear, h.latestPrice

OR CTE

WITH CrimesCTE AS (
    SELECT COUNT(IncidentNumber) AS CrimeOccurrencesAtZip, OccurredYear, zipcode 
	FROM Austin_Crime_Reports
	GROUP BY OccurredYear, zipcode
)
    
SELECT * 
FROM 
	(SELECT * FROM Austin_Housing_Inner) tb1 
	LEFT JOIN 
	(SELECT CrimeOccurrencesAtZip, OccurredYear, zipcode FROM CrimesCTE) tb2
		ON tb1.zipcode = tb2.zipcode 
		AND tb1.latest_saleyear = tb2.OccurredYear

--Commuters

WITH CrimesCTE AS (
    SELECT COUNT(IncidentNumber) AS CrimeOccurrencesAtZip, OccurredYear, zipcode 
	FROM Austin_Crime_Reports
	GROUP BY OccurredYear, zipcode
)
    
SELECT * 
FROM 
	(SELECT * FROM Austin_Housing_Commute) tb1 
	LEFT JOIN 
	(SELECT CrimeOccurrencesAtZip, OccurredYear, zipcode FROM CrimesCTE) tb2
		ON tb1.zipcode = tb2.zipcode 
		AND tb1.latest_saleyear = tb2.OccurredYear
