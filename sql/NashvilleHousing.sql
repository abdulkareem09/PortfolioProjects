Select *
From NashvilleHousing.dbo.NashvilleHousingTable

--Standarize Date Format 

Select SaleDate
From NashvilleHousing.dbo.NashvilleHousingTable


ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ALTER COLUMN   Date

--populate property address 
Select *
From NashvilleHousing.dbo.NashvilleHousingTable
--Where PropertyAddress is null
Order By ParcelID        

Select a.ParcelID , a.PropertyAddress ,b.ParcelID , b.PropertyAddress ,
ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousingTable a 
JOIN NashvilleHousing.dbo.NashvilleHousingTable b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where b.PropertyAddress is null
 
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.dbo.NashvilleHousingTable a 
JOIN NashvilleHousing.dbo.NashvilleHousingTable b 
ON a.ParcelID=b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking up Address into(Address , City ,State)
ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ADD PropertySplitAddress NvarChar(255)

UPDATE NashvilleHousing.dbo.NashvilleHousingTable
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1 ,CHARINDEX(',',PropertyAddress)-1)

Select *
From NashvilleHousing.dbo.NashvilleHousingTable

ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ADD PropertySplitCity NvarChar(255)

UPDATE NashvilleHousing.dbo.NashvilleHousingTable 
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1 , LEN(PropertyAddress))

ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashvilleHousing.dbo.NashvilleHousingTable
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing.dbo.NashvilleHousingTable 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashvilleHousing.dbo.NashvilleHousingTable 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing.dbo.NashvilleHousingTable 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousingTable 


--****
Select Distinct(SoldAsVacant) ,Count(SoldAsVacant)
From NashvilleHousing.dbo.NashvilleHousingTable
Group By SoldAsVacant
Order By 2 


UPDATE NashvilleHousing.dbo.NashvilleHousingTable
SET SoldAsVacant = 
     CASE WHEN SoldAsVacant='Y' THEN 'Yes'
          WHEN SoldAsVacant='N' THEN 'No'
	      ELSE SoldAsVacant
          END 


--Deleting Duplicates 

--Select *
--From NashvilleHousing.dbo.NashvilleHousingTable

WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER (
                   PARTITION BY ParcelID ,
                                PropertyAddress , 
								SalePrice,
						        SaleDate , 
								LegalReference 
								Order By UniqueID )  RowNum
From NashvilleHousing.dbo.NashvilleHousingTable )
DELETE 
From RowNumCTE
Where RowNum >1 


WITH RowNumCTE AS (
Select *,
ROW_NUMBER() OVER (
                   PARTITION BY ParcelID ,
                                PropertyAddress , 
								SalePrice,
						        SaleDate , 
								LegalReference 
								Order By UniqueID )  RowNum
From NashvilleHousing.dbo.NashvilleHousingTable )

DELETE 
From RowNumCTE
Where RowNum >1 


