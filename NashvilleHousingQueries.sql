SELECT *
FROM PortfolioProject2..NashvilleHousing

--standardize date format

SELECT SaleDateConverted, CONVERT(Date,Saledate)
FROM PortfolioProject2.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--property address data

SELECT * --PropertyAddress
FROM PortfolioProject2.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2.dbo.NashvilleHousing a
JOIN PortfolioProject2.dbo.NashvilleHousing b
	on a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--break out property address column

SELECT PropertyAddress
FROM PortfolioProject2.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD SplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing

--break out owner address column

SELECT OwnerAddress
FROM PortfolioProject2.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitOwnerAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD SplitOwnerCity NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD SplitOwnerState NVARCHAR(255);

UPDATE NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--change y to yes and n to no in sold as vacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject2.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant, CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject2.dbo.NashvilleHousing
ORDER BY 1

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) row_num
FROM PortfolioProject2.dbo.NashvilleHousing
)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT *
FROM RowNumCTE
WHERE row_num > 1


--delete unused columns

ALTER TABLE PortfolioProject2.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing