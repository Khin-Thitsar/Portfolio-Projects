--Data Cleaning
Select * from [Portfolio Project].[dbo].NashvilleHousing

--Standard date format
Select SaleDate, CONVERT (Date, SaleDate)as Date
from [Portfolio Project].[dbo].NashvilleHousing

update [Portfolio Project].[dbo].NashvilleHousing
set SaleDate = CONVERT (Date, SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

update [Portfolio Project].[dbo].NashvilleHousing
set SaleDateConverted = CONVERT (Date, SaleDate)

-- Populate Property adress data

Select PropertyAddress from [Portfolio Project].[dbo].NashvilleHousing
Where PropertyAddress is null

Select * from [Portfolio Project].[dbo].NashvilleHousing
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL (a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].[dbo].NashvilleHousing a
join [Portfolio Project].[dbo].NashvilleHousing b
on a.ParcelID =b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from [Portfolio Project].[dbo].NashvilleHousing a
join [Portfolio Project].[dbo].NashvilleHousing b
on a.ParcelID =b.ParcelID and
a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into individual coulums (address, city, state)

Select * from [Portfolio Project].[dbo].NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select 
SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1 ,LEN (PropertyAddress)) as Address
from [Portfolio Project].[dbo].NashvilleHousing


alter table [Portfolio Project].[dbo].NashvilleHousing
add SplitAddress varchar (225);

update [Portfolio Project].[dbo].NashvilleHousing
set SplitAddress = SUBSTRING(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

alter table [Portfolio Project].[dbo].NashvilleHousing
add City varchar (225);

update [Portfolio Project].[dbo].NashvilleHousing
set City = SUBSTRING(PropertyAddress, Charindex(',', PropertyAddress)+1 ,LEN (PropertyAddress)) 

Select * from [Portfolio Project].[dbo].NashvilleHousing


Select OwnerAddress from [Portfolio Project].[dbo].NashvilleHousing

Select 
PARSENAME (Replace (OwnerAddress,',','.'), 1), 
PARSENAME (Replace (OwnerAddress,',','.'), 2),
PARSENAME (Replace (OwnerAddress,',','.'), 3) 
from [Portfolio Project].[dbo].NashvilleHousing

alter table [Portfolio Project].[dbo].NashvilleHousing
add OwnerStreetAdress varchar (225);

update [Portfolio Project].[dbo].NashvilleHousing
set OwnerStreetAdress = PARSENAME (Replace (OwnerAddress,',','.'), 3) 

alter table [Portfolio Project].[dbo].NashvilleHousing
add OwnerCity varchar (225);

update [Portfolio Project].[dbo].NashvilleHousing
set OwnerCity = PARSENAME (Replace (OwnerAddress,',','.'), 2)

alter table [Portfolio Project].[dbo].NashvilleHousing
add OwnerState varchar (225);

update [Portfolio Project].[dbo].NashvilleHousing
set OwnerState = PARSENAME (Replace (OwnerAddress,',','.'), 1)

--Change Y to N or Yes to No in sold as vacant column

Select Distinct(SoldAsVacant), Count (SoldAsVacant)
from [Portfolio Project].[dbo].NashvilleHousing
Group by SoldAsVacant
Order By 2

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End
from [Portfolio Project].[dbo].NashvilleHousing



Update [Portfolio Project].[dbo].NashvilleHousing 
Set SoldAsVacant= Case When SoldAsVacant = 'Y' Then 'Yes'
When SoldAsVacant = 'N' Then 'No'
Else SoldAsVacant
End

--Remove Duplicates

With row_numCTE As (
Select *,
Row_number() over(
partition by ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
Order by UniqueID) Row_num
From [Portfolio Project].[dbo].NashvilleHousing)
--Order by ParcelID)
Select * from row_numCTE
Where row_num >1
order by PropertyAddress


--Remove unused Column

Alter Table [Portfolio Project].[dbo].NashvilleHousing
Drop  Column OwnerAddress, TaxDistrict, SaleDate, PropertyAddress

Select * from [Portfolio Project].[dbo].NashvilleHousing