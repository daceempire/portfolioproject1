SELECT * 
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------
--standardizing date format


SELECT SaleDate, SaleDateConverted
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate datetime

alter table PortfolioProject..NashvilleHousing
add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)
------------------------------------------------------------------------------------
--Populate property address data

SELECT * 
FROM PortfolioProject..NashvilleHousing
--where propertyaddress is null


SELECT NASH1.ParcelID, NASH1.PropertyAddress, NASH2.ParcelID, NASH2.PropertyAddress, ISNULL(NASH1.PropertyAddress,NASH2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS NASH1
JOIN PortfolioProject..NashvilleHousing AS NASH2
	ON NASH1.ParcelID = NASH2.ParcelID
	AND NASH1.[UniqueID ]<> NASH2.[UniqueID ]
WHERE NASH1.PropertyAddress is null

UPDATE NASH1
SET PropertyAddress = ISNULL(NASH1.PropertyAddress,NASH2.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS NASH1
JOIN PortfolioProject..NashvilleHousing AS NASH2
	ON NASH1.ParcelID = NASH2.ParcelID
	AND NASH1.[UniqueID ]<> NASH2.[UniqueID ]
WHERE NASH1.PropertyAddress is null

------------------------------------------------------------------------------------------------
--Breaking out address into different column i.e address, city, state


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as address
FROM PortfolioProject..NashvilleHousing

-- since we have split the property address table into 2, we will need to create 2 new tables under nashvillehousing table

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar;

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar;

alter table PortfolioProject..NashvilleHousing
alter column PropertySplitAddress nvarchar(255)

update PortfolioProject..NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

--noe seperating owner address as well

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing


alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject..NashvilleHousing
--where propertyaddress is null

--------------------------------------------------------------------------------------------------------------------
--Changing Y and N to yes and No in "sold as vacant" field



SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing



UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------
--remove duplicate, we wiil be using CTE to do this operation



WITH DupRem as (
SELECT *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				 UniqueID
				) num_row
FROM PortfolioProject..NashvilleHousing
)
select *
from DupRem
where num_row > 1

------------------------------------------------------------------------------------------------------
--Deleting unused column from thr table

SELECT *
FROM PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, TaxDistrict, OwnerAddress


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate


















