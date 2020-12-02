--*************************************************************************--
-- Title: Assignment07
-- Author: KFarrell
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2020-11-29,KFarrell,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_KFarrell')
	 Begin 
	  Alter Database [Assignment07DB_KFarrell] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_KFarrell;
	 End
	Create Database Assignment07DB_KFarrell;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_KFarrell;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers ********************************
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------' */
-- Question 1 (5 pts): What function can you use to show a list of Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the product!

-- <Put Your Code Here> --
SELECT 
	vProducts.ProductName as [PRODUCT],
	FORMAT(vProducts.UnitPrice, 'C2', 'en-US') as [PRICE]
FROM vProducts
ORDER BY ProductName;
go

-- Question 2 (10 pts): What function can you use to show a list of Category and Product names, 
-- and the price of each product, with the price formatted as US dollars?
-- Order the result by the Category and Product!

-- <Put Your Code Here> --
SELECT 
	vCategories.CategoryName AS [CATEGORY], 
	vProducts.ProductName as [PRODUCT],
	FORMAT(vProducts.UnitPrice, 'C2', 'en-US') as [PRICE]
FROM vProducts
JOIN vCategories
ON vCategories.CategoryID = vProducts.CategoryID
ORDER BY CategoryName, ProductName;

go

-- Question 3 (10 pts): What function can you use to show a list of Product names, 
-- each Inventory Date, and the Inventory Count, with the date formatted like "January, 2017?" 
-- Order the results by the Product, Date, and Count!

-- <Put Your Code Here> --
SELECT 
	vProducts.ProductName AS [PRODUCT],
	DATENAME(month,vInventories.InventoryDate) 
	+ ', ' + 
	DATENAME(yy,vInventories.InventoryDate)
	AS [DATE],
	vInventories.Count AS [INVENTORY COUNT]
FROM Assignment07DB_KFarrell.dbo.vProducts
JOIN Assignment07DB_KFarrell.dbo.vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY  ProductName, InventoryDate, Count;

go

-- Question 4 (10 pts): How can you CREATE A VIEW called vProductInventories 
-- That shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- with the date FORMATTED like January, 2017? Order the results by the Product, Date,
-- and Count!

-- <Put Your Code Here> --
CREATE VIEW dbo.vProductInventories AS
SELECT TOP 10000
	vProducts.ProductName AS [PRODUCT],
	DATENAME(month,vInventories.InventoryDate) 
	+ ', ' + 
	DATENAME(yy,vInventories.InventoryDate)
	AS [DATE],
	vInventories.Count AS [INVENTORYCOUNT]
FROM Assignment07DB_KFarrell.dbo.vProducts
JOIN Assignment07DB_KFarrell.dbo.vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY  vProducts.ProductName, InventoryDate, Count;
go


-- Check that it works: Select * From vProductInventories;
Select * From dbo.vProductInventories;
--drop view dbo.vProductInventories;
go

-- Question 5 (15 pts): How can you CREATE A VIEW called vCategoryInventories 
-- that shows a list of Category names, Inventory Dates, 
-- and a TOTAL Inventory Count BY CATEGORY, with the date FORMATTED like January, 2017?

-- <Put Your Code Here> --

CREATE TABLE #CategoryCounts
([CATEGORY] [nvarchar](100) NOT NULL
 ,[DATE] [nvarchar](100) NOT NULL
 ,[INVENTORYCOUNT] [int] NOT NULL
 )
INSERT INTO #CategoryCounts
SELECT
	vCategories.CategoryName AS [CATEGORY],
	DATENAME(month,vInventories.InventoryDate) 
	+ ', ' + 
	DATENAME(yy,vInventories.InventoryDate)
	AS [DATE],
	vInventories.Count AS [INVENTORY COUNT]
FROM Assignment07DB_KFarrell.dbo.vCategories
JOIN Assignment07DB_KFarrell.dbo.vProducts
ON vProducts.CategoryID = vProducts.CategoryID
JOIN Assignment07DB_KFarrell.dbo.vInventories
ON vProducts.ProductID = vInventories.ProductID
ORDER BY  vCategories.CategoryName, InventoryDate, Count;
go

--SELECT *  FROM #CategoryCounts;

--SELECT CATEGORY, DATE, SUM(INVENTORYCOUNT) AS [INVENTORY COUNT]
--FROM #CategoryCounts
--GROUP BY CATEGORY, DATE;
--go

DROP TABLE #CategoryCounts;
go

CREATE VIEW dbo.vCategoryInventories AS
SELECT TOP 10000
	vCategories.CategoryName AS [CATEGORY],
	DATENAME(month,vInventories.InventoryDate) 
	+ ', ' + 
	DATENAME(yy,vInventories.InventoryDate)
	AS [DATE],
	SUM(vInventories.Count) AS [INVENTORY COUNT]
FROM Assignment07DB_KFarrell.dbo.vCategories
JOIN Assignment07DB_KFarrell.dbo.vProducts
ON vProducts.CategoryID = vProducts.CategoryID
JOIN Assignment07DB_KFarrell.dbo.vInventories
ON vProducts.ProductID = vInventories.ProductID
GROUP BY  vCategories.CategoryName, InventoryDate
ORDER BY CategoryName, InventoryDate;
go

--DROP VIEW vCategoryInventories;

-- Check that it works: Select * From vCategoryInventories;
Select * From vCategoryInventories;
go

-- Question 6 (10 pts): How can you CREATE ANOTHER VIEW called 
-- vProductInventoriesWithPreviouMonthCounts to show 
-- a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month
-- Count? Use a functions to set any null counts or 1996 counts to zero. Order the
-- results by the Product, Date, and Count. This new view must use your
-- vProductInventories view!

-- <Put Your Code Here> --

CREATE TABLE PreviousMonthCounts
([PRODUCT] [nvarchar] (100) NOT NULL
,[DATE] [nvarchar](100) NOT NULL
,[INVENTORYCOUNT] [int] NOT NULL
,[PREVIOUSMONTHCOUNT] [int]
)
INSERT INTO PreviousMonthCounts
SELECT
	C.PRODUCT AS [PRODUCT],
	C.DATE AS [DATE],
	C.INVENTORYCOUNT AS [INVENTORYCOUNT],
	[PREVIOUSMONTHCOUNT] = CASE 
							When  (C.DATE = 'February, 2017' AND  P.DATE = 'January, 2017') Then P.INVENTORYCOUNT
							When  (C.DATE = 'March, 2017' AND  P.DATE = 'February, 2017') Then P.INVENTORYCOUNT
							When  (C.DATE = 'January, 2017' AND  P.DATE = 'January, 2017') Then 0
							End
FROM Assignment07DB_Kfarrell.dbo.vProductInventories AS C
INNER JOIN Assignment07DB_KFarrell.dbo.vProductInventories AS P
ON C.Product = P.Product;
go
Create View vProductInventoriesWithPreviousMonthCounts AS
select PRODUCT, DATE, INVENTORYCOUNT, PREVIOUSMONTHCOUNT 
from PreviousMonthCounts where PREVIOUSMONTHCOUNT is not null;
go

--drop View vProductInventoriesWithPreviousMonthCounts;
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15 pts): How can you CREATE one more VIEW 
-- called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month 
-- Count and a KPI that displays an increased count as 1, 
-- the same count as 0, and a decreased count as -1? Order the results by the Product, Date, and Count!
--ALTER TABLE PreviousMonthCounts
--	ADD KPI int;
--INSERT INTO PreviousMonthCounts (KPI)
--	KPI
-- <Put Your Code Here> --
--drop View vProductInventoriesWithPreviousMonthCountsWithKPIs;
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs AS
	SELECT
	P.PRODUCT as [PRODUCT], 
	P.DATE as [DATE], 
	P.INVENTORYCOUNT as [INVENTORYCOUNT], 
	P.PREVIOUSMONTHCOUNT as [PREVIOUSMONTHCOUNT],
	KPI = CASE
			When (P.INVENTORYCOUNT > P.PREVIOUSMONTHCOUNT) then 1
			When (P.INVENTORYCOUNT < P.PREVIOUSMONTHCOUNT) then -1
			When (P.INVENTORYCOUNT = P.PREVIOUSMONTHCOUNT) then 0
			End
	FROM vProductInventoriesWithPreviousMonthCounts AS P;
go

-- Check that it works: 
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25 pts): How can you CREATE a User Defined Function (UDF) 
-- called fProductInventoriesWithPreviousMonthCountsWithKPIs
-- to show a list of Product names, Inventory Dates, Inventory Count, the Previous Month
-- Count and a KPI that displays an increased count as 1, the same count as 0, and a
-- decreased count as -1 AND the result can show only KPIs with a value of either 1, 0,
-- or -1? This new function must use you
-- ProductInventoriesWithPreviousMonthCountsWithKPIs view!
-- Include an Order By clause in the function using this code: 
-- Year(Cast(v1.InventoryDate as Date))
-- and note what effect it has on the results.

-- <Put Your Code Here> --
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@KPIId INT)
 RETURNS TABLE
 AS
  RETURN (
  SELECT TOP 100000
  PRODUCT, DATE, INVENTORYCOUNT, PREVIOUSMONTHCOUNT, KPI
  FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS v1
   WHERE KPI = @KPIId
   ORDER BY Year(Cast(v1.DATE as Date))
  );
go


--SELECT PRODUCT, DATE, INVENTORYCOUNT, PREVIOUSMONTHCOUNT, KPI
--  FROM vProductInventoriesWithPreviousMonthCountsWithKPIs as v1
--  ORDER BY Year(Cast(v1.DATE as Date));

--drop FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs
--Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);

go

/***************************************************************************************/