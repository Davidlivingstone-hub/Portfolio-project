select *
From portfolioproject.dbo.['Nash housing data$']


-- Standardize date format


select cleandate
from portfolioproject..['Nash housing data$']

update ['Nash housing data$']
set saledate = convert (date,saledate)

ALTER TABLE ['Nash housing data$']
ADD Cleandate DATE;

UPDATE ['Nash housing data$']
SET CleanDate = CAST(SaleDate AS DATE);



-- Populate property address data
 
 select *
 from portfolioproject..['Nash housing data$']
 where PropertyAddress is  null
 order by ParcelID

 select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
 from portfolioproject..['Nash housing data$'] a
 join portfolioproject..['Nash housing data$'] b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = b.PropertyAddress
FROM portfolioproject..['Nash housing data$'] a
JOIN portfolioproject..['Nash housing data$'] b
    ON a.ParcelID = b.ParcelID
    AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;



-- breaking out address into individual columns (address, city, state)


select propertyaddress
from portfolioproject..['Nash housing data$']

ALTER TABLE ['Nash housing data$']
ADD PropertySplitAddress NVARCHAR(255);

UPDATE ['Nash housing data$']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE ['Nash housing data$']
ADD PropertySplitCity NVARCHAR(255);

UPDATE ['Nash housing data$']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

select *
from ['Nash housing data$']

-- owner address
select
parsename (replace(owneraddress, ',', '.'),3),
parsename (replace(owneraddress, ',', '.'),2),
parsename (replace(owneraddress, ',', '.'),1)
from portfolioproject..['Nash housing data$']

ALTER TABLE ['Nash housing data$']
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE ['Nash housing data$']
SET OwnerSplitAddress = parsename (replace(owneraddress, ',', '.'),3)

ALTER TABLE ['Nash housing data$']
ADD OwnerSplitCity NVARCHAR(255);

UPDATE ['Nash housing data$']
SET OwnerSplitCity= parsename (replace(owneraddress, ',', '.'),2)

ALTER TABLE ['Nash housing data$']
ADD OwnerSplitstate NVARCHAR(255);

UPDATE ['Nash housing data$']
SET OwnerSplitstate= parsename (replace(owneraddress, ',', '.'),1)


--change Y and N to Yes and No in "Sold as Vacant' field 

select distinct (soldasvacant), count(soldasvacant)
from portfolioproject..['Nash housing data$']
group by SoldAsVacant
order by 2

select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end
from portfolioproject..['Nash housing data$']

update ['Nash housing data$']
set SoldasVacant = case when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
else soldasvacant
end


