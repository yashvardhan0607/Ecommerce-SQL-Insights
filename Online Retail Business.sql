/*

Project Overview: Fictional Online Retail Company
--------------------------------------
A.	Database Design
	-- Database Name: OnlineRetailDB

B.	Tables:
	-- Customers: Stores customer details.
	-- Products: Stores product details.
	-- Orders: Stores order details.
	-- OrderItems: Stores details of each item in an order.
	-- Categories: Stores product categories.

C.	Insert Sample Data:
	-- Populate each table with sample data.

D. Write Queries:
	-- Retrieve data (e.g., customer orders, popular products).
	-- Perform aggregations (e.g., total sales, average order value).
	-- Join tables for comprehensive reports.
	-- Use subqueries and common table expressions (CTEs).
*/

/* LET'S GET STARTED */

-- Create the database
CREATE DATABASE OnlineRetailDB;
GO

-- Use the database
USE OnlineRetailDB;
Go

-- Create the Customers table
CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products table
CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories table
CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

-- Create the Orders table
CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Alter / Rename the Column Name
EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'COLUMN'; 

-- Create the OrderItems table
CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

-- Insert sample data into Categories table
INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);



-- Creating a store procedure to anlayse all the table at once

Create proc SEE as
Begin
	Select * from OrderItems
	Select * from Orders
	Select * from Products
	Select * from Customers
	Select * from Categories

End

 


--Query 1: Retrieve all orders for a specific customer

SELECT o.OrderID, o.OrderDate, o.TotalAmount, oi.ProductID, p.ProductName, oi.Quantity, oi.Price
FROM Orders o
JOIN OrderItems oi ON o.OrderId = oi.OrderID
JOIN Products p ON oi.ProductID = p.ProductID
WHERE o.CustomerID = 1;

--Query 2: Find the total sales for each product

SELECT p.ProductID, p.ProductName, SUM(oi.Quantity * oi.Price) AS TotalSales
FROM OrderItems oi
JOIN Products p 
ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.ProductName
ORDER BY TotalSales DESC;


--Query 3: Calculate the average order value
SELECT AVG(TotalAmount) AS AverageOrderValue FROM Orders;

--Query 4: List the top 5 customers by total spending

Select Top 5 * from (Select O.CustomerID, FirstName +' '+ LastName as Customer_Name,TotalAmount
from Orders O
Join Customers C
On C.CustomerID = O.CustomerID
Group by O.CustomerID, TotalAmount, FirstName +' '+ LastName) A
Order by TotalAmount desc


--Query 5: Retrieve the most popular product category

With CTE as 
(Select C.CategoryID, CategoryName, Sum(OI.Quantity) as Total_Quatity_Sold,
ROW_NUMBER() Over (Order by Sum(OI.Quantity) Desc) rn
From OrderItems OI
Join Products P On P.ProductID = OI.ProductID
Join Categories C On C.CategoryID = P.CategoryID
Group By CategoryName, C.CategoryID)

Select CategoryID, CategoryName, Total_Quatity_Sold from CTE 
where rn = 1

-- Write a query to display the category and the product that has not been sold once.

Select P.ProductID, P.ProductName, CategoryID, Sum(Quantity) As Quantity_Sold
from OrderItems OI
Right Join Products P On P.ProductID = OI.ProductID
WHERE P.ProductID NOT IN (SELECT ProductID FROM OrderItems)
Group by P.ProductID, P.ProductName, CategoryID


--Query 7: Find customers who placed orders in the last 30 days


With CTE as 
(select O.CustomerID, FirstName+' ' +LastName as Name, Email, Phone, DATEDIFF(Day, OrderDate, Getdate()) as DAYSS
from Orders O
Join Customers C on C.CustomerID = O.CustomerID) 

Select CustomerID, Name,Email, Phone from CTE where DAYSS < 30 


--Query 8: Calculate the total number of orders placed each month

SELECT YEAR(OrderDate) as OrderYear,
MONTH(OrderDate) as OrderMonth,
COUNT(OrderID) as TotalOrders
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;


--Query 9: Retrieve the details of the most recent order

Select Top 1 OrderId, O.CustomerID, Upper(FirstName+ ' '+ LastName) as Customer_Name, Email,Phone,OrderDate, TotalAmount 
From Orders O
Join Customers C On C.CustomerID = O.CustomerID
Order by OrderDate desc


--Query 10: Find the average price of products in each category

-- FYR: Query 6
-- SELECT p.ProductID, p.ProductName, c.CategoryName, p.Stock 
-- FROM Products p JOIN Categories c
-- ON p.CategoryID = c.CategoryID
-- WHERE Stock = 0;

--Query 11: List customers who have never placed an order


--Query 12: Retrieve the total quantity sold for each product


--Query 13: Calculate the total revenue generated from each category


--Query 14: Find the highest-priced product in each category


--Query 15: Retrieve orders with a total amount greater than a specific value (e.g., $500)

--Query 16: List products along with the number of orders they appear in

--Query 17: Find the top 3 most frequently ordered products

--Query 18: Calculate the total number of customers from each country

--Query 19: Retrieve the list of customers along with their total spending


--Query 20: List orders with more than a specified number of items (e.g., 5 items)
