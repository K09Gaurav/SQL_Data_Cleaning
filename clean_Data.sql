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

