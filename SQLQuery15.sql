SELECT *
FROM Nashville.dbo.NashvilleHousing 


-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Nashville.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address data

SELECT *
FROM Nashville.dbo.NashvilleHousing 
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville.dbo.NashvilleHousing a
JOIN Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville.dbo.NashvilleHousing a
JOIN Nashville.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

SELECT ParcelID, PropertyAddress
FROM Nashville.dbo.NashvilleHousing a

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Nashville.dbo.NashvilleHousing 
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
FROM Nashville.dbo.NashvilleHousing 

SELECT
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Nashville.dbo.NashvilleHousing 

USE Nashville

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


SELECT * 
FROM Nashville.dbo.NashvilleHousing 

SELECT OwnerAddress
FROM Nashville.dbo.NashvilleHousing 

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM Nashville.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashvilleHousing


-- Change Y and N to Yess and No in "Sold as Vacant" Field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Nashville.dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2 


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Nashville.dbo.NashvilleHousing 


UPDATE NashvilleHousing 
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates


WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					)  as row_num
FROM Nashville.dbo.NashvilleHousing 
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE 
WHERE row_num > 1
--ORDER BY PropertyAddress




SELECT *
FROM Nashville.dbo.NashvilleHousing 


-- Delete Unused Columns


ALTER TABLE Nashville.dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
