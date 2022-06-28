--
---Data Cleaning SQL Project
--

------------------------------------------------------
-- 1. Select ALL from Database

SELECT *
FROM ProjectPortfolio2..NashvilleHousing

------------------------------------------------------
-- 2. Standardize Date Format

SELECT SaleDate
FROM ProjectPortfolio2..NashvilleHousing <-- look at first

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM ProjectPortfolio2..NashvilleHousing  <-- view a quick convert

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) <-- write the update (if not working, use below)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; <--New Column

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) <-- Add to new column

SELECT SaleDateConverted
FROM ProjectPortfolio2..NashvilleHousing <--Verify with a view


------------------------------------------------------
-- 3. Populate Property Address Data

SELECT *
FROM ProjectPortfolio2..NashvilleHousing
WHERE PropertyAddress is null <--Check if nulls first

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
		ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectPortfolio2..NashvilleHousing a
JOIN ProjectPortfolio2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null  <--View the join first, before updating below

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProjectPortfolio2..NashvilleHousing a
JOIN ProjectPortfolio2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null <--Update it!


------------------------------------------------------
-- 4. Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM ProjectPortfolio2..NashvilleHousing <-- View the column

SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM ProjectPortfolio2..NashvilleHousing <--Look for specific values

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); <--New Column (Address)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) <--Add to new Column

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); <--New Column (City)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) <--Add to new Column


------------------------------------------------------
-- 5. Breaking out Owner Address into Individual Columns, in a different way with a Parse (Address, City, State)


SELECT OwnerAddress
FROM ProjectPortfolio2..NashvilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM ProjectPortfolio2..NashvilleHousing <--View as Example (1,2,3 produces results backwards, try 3, 2, 1)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255); <--New Column (Address)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3) <--Add to new Column

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255); <--New Column (City)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2) <--Add to new Column

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255); <--New Column (City)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1) <--Add to new Column


------------------------------------------------------
-- 5. Change Y and N to Yes and No respectively in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM ProjectPortfolio2..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 <-- Check the count for all these


SELECT SoldAsVacant,
	   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
FROM ProjectPortfolio2..NashvilleHousing <--Test a view

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END

------------------------------------------------------
-- 6. Remove Duplicates (Write as CTE with Windows Functions)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio2..NashvilleHousing
--ORDER BY ParcelID <--Test with a view
)
--SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM ProjectPortfolio2..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress <--View if delete worked

------------------------------------------------------
-- 7. Delete Unused Columns

SELECT *
FROM ProjectPortfolio2..NashvilleHousing

ALTER TABLE ProjectPortfolio2..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



