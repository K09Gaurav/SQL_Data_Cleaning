/*
Taking a peek at the data to be working on
*/

select TOP(50)* 
from dbo.Housing_Data

--------------------------------------------------------

--Observed the Data was in this Format "2013-04-09 00:00:00.000"
--SInce there is no need for TIME , will change the Date Format

--Preview what to expect

select SaleDate , Convert(Date,SaleDate)
from dbo.Housing_Data

--Update it

ALTER TABLE dbo.Housing_Data
Add SaleDateConverted Date;


UPDATE dbo.Housing_Data
SET SaleDateConverted = Convert(Date,SaleDate)

--Now delete the previous COlumn of Date

ALTER TABLE dbo.Housing_Data
drop COLUMN SaleDate

--------------------------------------------------------

--There are some null values in Property Address and owners name
--WIll fill them up if there is data present in the TABLE itself

--Checked if there is any parcel id that is null
select ParcelID
from Houses.dbo.Housing_data
where ParcelID is null
-- NO Null value found


--Searched Parcel if where Property address is null 
select *
from Houses.dbo.Housing_data
where PropertyAddress is null
order by ParcelID
--29 Property address found NULL


--Joining them together

select a.ParcelID ,a.PropertyAddress,
		b.ParcelID ,b.PropertyAddress
from 
	Houses.dbo.Housing_data a 
	JOIN
	Houses.dbo.Housing_data b
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]

--Using another column to preview what to Insert in the values that are null in col

select a.ParcelID ,a.PropertyAddress,
		b.ParcelID ,b.PropertyAddress,
		 ISNULL(a.PropertyAddress,b.PropertyAddress) AS Null_Value
from 
	Houses.dbo.Housing_data a 
	JOIN
	Houses.dbo.Housing_data b
on a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]

--So we will take the column we created and put it inside the Column 

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from 
	Houses.dbo.Housing_data a 
	JOIN
	Houses.dbo.Housing_data b
on a.ParcelID = b.ParcelID AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

--SInce there is no Null Value in Property address col we dont need to but
--If we had Null values
--We could have replaced the Null Value to "No Address Availaible"

UPDATE Houses.dbo.Housing_data
SET PropertyAddress = 'No Address Availaible'
Where PropertyAddress is null

----------------------------------------------------------------------------------

/*
Unable to do the same with Owner Name
as the Owner Name for missing Values are entirely Missing From The table there is no case like The address one
*/
-- So i will Just replace the null values with Name Not availaible

UPDATE Houses.dbo.Housing_data
SET OwnerName = 'No Address Availaible'
Where OwnerName is null

------------------------------

/* Partitioning the property Column as the column contains very large values
As it have Home,tow, city address as well
*/

-- The delimiter in the property col is a comma ','
-- We can use substring to separate them BY FINDING the comma using CHARINDEX

--Syntax of them:

-- SUBSTring(expression, start, length)
--CHARINDEX ( expressionToFind , expressionToSearch [ , start_location ] )


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address ,PropertyAddress
from Houses.dbo.Housing_data

--Substring Starting position is 1 and ending position is CHARINDEX(',',PropertyAddress)


--Removed comma from the end of address
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address ,PropertyAddress
from Houses.dbo.Housing_data

--For the City Name

select SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress), LEN(PropertyAddress)) AS Address ,PropertyAddress
from Houses.dbo.Housing_data
 
 --Used Substring Starting position is CHARINDEX(',',PropertyAddress)+1  (+1 is used to remove the comma )
 -- and ending position is LEN(PropertyAddress)

 --Final Adress comparison
 
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address ,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City,
PropertyAddress
from Houses.dbo.Housing_data


--Now add both of these columns to the table by creating new ones

ALTER TABLE Houses.dbo.Housing_data
ADD BaseAddress varchar(60),
	City varchar(30);

--Input the values

UPDATE Houses.dbo.Housing_data
SET BaseAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

UPDATE Houses.dbo.Housing_data
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

-----------------------------------------------------------------------------------------------------

--DO the same with Owner Address
--We can do this using 2 ways 
--previous and PARSENAME

select SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)-1) AS OAddress 
,OwnerAddress
from Houses.dbo.Housing_data

--Taken starting point of substring from 'position of coma' + 1
--to length of col 
select SUBSTRING(OwnerAddress, LEN(SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)+2)), LEN(OwnerAddress)) AS OCityAddress 
,OwnerAddress
from Houses.dbo.Housing_data


with TEmp (OStateAddress)as (
select SUBSTRING(OwnerAddress, LEN(SUBSTRING(OwnerAddress, 1, CHARINDEX(',',OwnerAddress)+2)), LEN(OwnerAddress)) 
from Houses.dbo.Housing_data)
select SUBSTRING(OStateAddress, 1,  CHARINDEX(',',OStateAddress)-1) AS STATEAddress
from TEmp


-----------------------

--Now use PARSENAME
--ParseName returns specified part of object
--                                                           Starts from back

--PARSENAME ('object_name' , object_piece )


SELect
PARSENAME(OwnerAddress, 1) as OwnerAddress,
PARSENAME(OwnerAddress, 2) as OwnerAddress,
PARSENAME(OwnerAddress, 3) as OwnerAddress
from Houses..Housing_Data

--This shows NULL as PARSENAME only delimiter is '.' but we have ',' in our addresses
--WE will replace ',' with '.' then it will work


SELect
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as OwnerState,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as OwnercITY,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as OwnerAddress
from Houses..Housing_Data

--Works fine now update it into TABLE


ALTER TABLE Houses..Housing_Data
ADD OwnerBaseAddress varchar(70);


ALTER TABLE Houses..Housing_Data
ADD OwnerCity varchar(70);


ALTER TABLE Houses..Housing_Data
ADD OwnerState varchar(70);

UPDATE Houses..Housing_Data
SET OwnerBaseAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


UPDATE Houses..Housing_Data
SET OwnercITY = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)


UPDATE Houses..Housing_Data
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


----------------------------------------------------------------------

/*Sold as Vacant got 4 diff values instead of being only 4
N Yes Y No 
We have to change that to only Yes and No
*/

select SoldAsVacant
from Houses..Housing_Data
group by SoldAsVacant

UPDATE Houses..Housing_Data
SET SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

UPDATE Houses..Housing_Data
SET SoldAsVacant = 'No'
where SoldAsVacant = 'N'


--OR

Update Houses..Housing_Data
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   					When SoldAsVacant = 'N' THEN 'No'
	   					ELSE SoldAsVacant
	   				END

-----------------------------------------------------------------

-- Remove any duplicates if availaible

--Finding Duplicates based on  ParcelID, SaleDateConverted and  LegalReference as all 3 of them combined shouldn't be same

With RowNUM as (
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,SaleDateConverted, LegalReference order BY UniqueID ) as Row_NUMBERS
from Houses..Housing_Data)
select * from RowNUM where Row_NUMBERS >1

--104 rows found which are duplicates


With RowNUM as (
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,SaleDateConverted, LegalReference order BY UniqueID ) as Row_NUMBERS
from Houses..Housing_Data)
DELETE from RowNUM where Row_NUMBERS >1

