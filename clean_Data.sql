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

