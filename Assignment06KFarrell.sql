--*************************************************************************--
-- Title: Assignment06
-- Author: KFarrell
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-11-21,KFarrell,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_KFarrell')
	 Begin 
	  Alter Database [Assignment06DB_KFarrell] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_KFarrell;
	 End
	Create Database Assignment06DB_KFarrell;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_KFarrell;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories
WITH SCHEMABINDING
AS
 SELECT
  CategoryID, CategoryName
 FROM 
  dbo.Categories
;
go

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
 SELECT
  ProductID, ProductName, CategoryID, UnitPrice
 FROM
  dbo.Products
;
go

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
 SELECT
  EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
 FROM 
  dbo.Employees
;
go

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
 SELECT
  InventoryID, InventoryDate, EmployeeID, ProductID, Count
 FROM
  dbo.Inventories
;
go
-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON dbo.Categories to Public;
DENY SELECT ON Products to Public;
DENY SELECT ON Employees to Public;
DENY SELECT ON Inventories to Public;
go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
CREATE VIEW dbo.vProductsByCategories AS
SELECT TOP 100 PERCENT 
  CategoryName AS [Category], 
  ProductName AS [Product names], 
  UnitPrice AS [price]
FROM Assignment06DB_KFarrell.dbo.Categories
JOIN Assignment06DB_KFarrell.dbo.Products
ON Categories.CategoryID = Products.CategoryID
ORDER BY CategoryName, ProductName;
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83
CREATE VIEW dbo.vInventoriesByProductsByDates AS
SELECT TOP 100 PERCENT 
  ProductName AS [Product], 
  Count AS [Inventory Counts], 
  InventoryDate AS [Inventory Date]
FROM Assignment06DB_KFarrell.dbo.Products
JOIN Assignment06DB_KFarrell.dbo.Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY ProductName, InventoryDate, Count;
go

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth
CREATE VIEW dbo.vInventoriesByEmployeesByDates AS
SELECT DISTINCT TOP 100 PERCENT 
  InventoryDate as [Inventory Dates], 
  EmployeeFirstName + ' ' + EmployeeLastName AS [Employee]
FROM Assignment06DB_KFarrell.dbo.Inventories
JOIN Assignment06DB_KFarrell.dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate;
go

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54
CREATE VIEW vInventoriesByProductsByCategories AS
SELECT TOP 100 PERCENT
       CategoryName as [Category],
       ProductName as [Product],
	   InventoryDate as [Date],
	   Count as [Count]
FROM Assignment06DB_KFarrell.dbo.Products
JOIN Assignment06DB_KFarrell.dbo.Categories
ON Categories.CategoryID = Products.CategoryID
JOIN Assignment06DB_KFarrell.dbo.Inventories
ON Products.ProductID = Inventories.ProductID
ORDER BY CategoryName, ProductName, InventoryDate, Count;
go


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan
CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT TOP 100 PERCENT
       CategoryName as [Category],
       ProductName as [Product],
	   InventoryDate as [Date],
	   Count as [Count],
	   EmployeeFirstName + ' ' + EmployeeLastName as [EmployeeName]
FROM Assignment06DB_KFarrell.dbo.Products
JOIN Assignment06DB_KFarrell.dbo.Categories
ON Categories.CategoryID = Products.CategoryID
JOIN Assignment06DB_KFarrell.dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN Assignment06DB_KFarrell.dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeLastName;
go


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King
CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT TOP 100 PERCENT
       CategoryName as [Category],
       ProductName as [Product],
	   InventoryDate as [Date],
	   Count as [Count],
	   EmployeeFirstName + ' ' + EmployeeLastName as [EmployeeName]
FROM Assignment06DB_KFarrell.dbo.Products
JOIN Assignment06DB_KFarrell.dbo.Categories
ON Categories.CategoryID = Products.CategoryID
JOIN Assignment06DB_KFarrell.dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN Assignment06DB_KFarrell.dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID
 WHERE Products.ProductID IN
   (SELECT Products.ProductID 
    FROM Assignment05DB_KFarrell.dbo.Products 
	WHERE ProductName IN ('Chai', 'Chang'))
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeLastName;
go

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan
CREATE VIEW vEmployeesByManager AS
SELECT TOP 100 PERCENT
M.EmployeeFirstName + ' ' + M.EmployeeLastName AS Manager,
E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
FROM Assignment06DB_KFarrell.dbo.Employees AS E
INNER JOIN Assignment06DB_KFarrell.dbo.Employees AS M
ON E.ManagerID = M.EmployeeID
ORDER BY M.EmployeeFirstName, M.EmployeeLastName;
go



-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT TOP 100 PERCENT
       Categories.CategoryID AS [CategoryID],
       Categories.CategoryName AS [CategoryName],
	   Products.ProductID AS [ProductID],
	   Products.ProductName AS [ProductName],
	   Products.UnitPrice AS [UnitPrice],
	   Inventories.InventoryID AS [InventoryID],
	   Inventories.InventoryDate AS [InventoryDate],
	   Inventories.Count AS [Count],
	   Employees.EmployeeID AS [EmployeeID],
	   Employees.EmployeeFirstName + ' ' + Employees.EmployeeLastName AS [Employee],
	   M.EmployeeFirstName + ' ' + M.EmployeeLastName AS [Manager]
FROM Assignment06DB_KFarrell.dbo.Categories
JOIN Assignment06DB_KFarrell.dbo.Products
ON Categories.CategoryID = Products.CategoryID
JOIN Assignment06DB_KFarrell.dbo.Inventories
ON Products.ProductID = Inventories.ProductID
JOIN Assignment06DB_KFarrell.dbo.Employees
ON Inventories.EmployeeID = Employees.EmployeeID
INNER JOIN Assignment06DB_KFarrell.dbo.Employees AS M
ON Employees.ManagerID = M.EmployeeID
ORDER BY CategoryID, ProductID;
go

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/