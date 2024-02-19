
-- DATA CLEANING PRACTICE


Select *
From PortfolioProject.dbo.NationalHousing

-- Standardizing Date Format
ALTER TABLE NationalHousing
Add SaleDateConverted Date

Update NationalHousing
SET SaleDateConverted =  CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NationalHousing


-- Populate Property Address Date

Select *
From PortfolioProject.dbo.NationalHousing
--Where PropertyAddress is NULL
order by ParcelID

-- Querying out the NULL Property Address in the Table
Select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress
, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NationalHousing a
	JOIN PortfolioProject.dbo.NationalHousing b
	on  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-- Updating NationalHousing Table to have its PropertyAddress values filled
-- and not NULLED
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NationalHousing a
	JOIN PortfolioProject.dbo.NationalHousing b
	on  a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL

-- Breaking out Address into Individual Columnss (Address, City, State)  

Select PropertyAddress
From PortfolioProject.dbo.NationalHousing
order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress ) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress ) +1, LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.NationalHousing

-- Putting the above into two new different columns to make 
-- the effect

ALTER TABLE PortfolioProject.dbo.NationalHousing
Add PropertySplitAddress nvarchar(255)

Update PortfolioProject.dbo.NationalHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress ) -1)

ALTER TABLE PortfolioProject.dbo.NationalHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NationalHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress ) +1, LEN(PropertyAddress))




Select OwnerAddress
From PortfolioProject.dbo.NationalHousing

--the PARSENAME is a better option for the spliting
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NationalHousing


ALTER TABLE PortfolioProject.dbo.NationalHousing
Add OwnerSplitAddress nvarchar(255)

Update PortfolioProject.dbo.NationalHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject.dbo.NationalHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NationalHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject.dbo.NationalHousing
Add OwnerSplitState nvarchar(25);

Update PortfolioProject.dbo.NationalHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Change Y and N to yes and no in "Sold as vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NationalHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject.dbo.NationalHousing

UPDATE PortfolioProject.dbo.NationalHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


---- Remove duplicates ------

-- seeing the duplicate rows
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,	
		     SaleDate,
		     LegalReference
		     ORDER BY 
			UniqueID		
			) row_num
From PortfolioProject.dbo.NationalHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order By  PropertyAddress


--deleting the duplicate rows
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
		     PropertyAddress,
		     SalePrice,	
		     SaleDate,
		     LegalReference
		     ORDER BY 
			UniqueID		
			) row_num
From PortfolioProject.dbo.NationalHousing
)
DELETE
From RowNumCTE
Where row_num > 1


----- Deleting unused columns-----

Select * 
From PortfolioProject.dbo.NationalHousing

ALTER TABLE PortfolioProject.dbo.NationalHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

