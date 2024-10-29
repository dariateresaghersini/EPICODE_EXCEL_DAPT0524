CREATE DATABASE ToysGroupDB;
USE ToysGroupDB;

CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(50) NOT NULL
);

CREATE TABLE Product (
    ProductID INT PRIMARY KEY AUTO_INCREMENT,
    ProductName VARCHAR(50) NOT NULL,
    CategoryID INT NOT NULL,
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
    RegionID INT PRIMARY KEY AUTO_INCREMENT,
    RegionName VARCHAR(50) NOT NULL
);

CREATE TABLE Country (
    CountryID INT PRIMARY KEY AUTO_INCREMENT,
    CountryName VARCHAR(50) NOT NULL,
    RegionID INT NOT NULL,
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

CREATE TABLE Sales (
    SalesID INT PRIMARY KEY AUTO_INCREMENT,
    ProductID INT NOT NULL,
    RegionID INT NOT NULL,
    SaleDate DATE NOT NULL,
    Quantity INT NOT NULL,
    SaleAmount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
    FOREIGN KEY (RegionID) REFERENCES Region(RegionID)
);

-- Insert Categories
INSERT INTO Category (CategoryName) VALUES
('Bikes'),
('Clothing'),
('Accessories'),
('Scooters'),
('Camping Gear');

-- Insert Products
INSERT INTO Product (ProductName, CategoryID) VALUES
('Bikes-100', 1),
('Bikes-200', 1),
('Bike Glove M', 2),
('Bike Glove L', 2),
('Helmet', 3),
('Scooter-300', 4),
('Scooter-400', 4),
('Tent', 5),
('Sleeping Bag', 5),
('Bike Water Bottle', 2),
('Bike Pump', 1),            -- Unsold Product
('Child\'s Bicycle', 1);     -- Unsold Product

-- Insert Regions
INSERT INTO Region (RegionName) VALUES
('WestEurope'),
('SouthEurope'),
('NorthAmerica'),
('EastEurope'),
('Asia');

-- Insert Countries
INSERT INTO Country (CountryName, RegionID) VALUES
('France', 1),
('Germany', 1),
('Italy', 2),
('Greece', 2),
('USA', 3),
('Canada', 3),
('Poland', 4),
('Czech Republic', 4),
('China', 5),
('Japan', 5),
('Australia', 3);

-- Insert Sales
INSERT INTO Sales (ProductID, RegionID, SaleDate, Quantity, SaleAmount) VALUES
(1, 1, '2023-07-15', 5, 499.99),   -- Bikes-100
(2, 2, '2024-01-20', 3, 299.99),   -- Bikes-200
(3, 3, '2024-02-10', 10, 199.99),  -- Bike Glove M
(4, 1, '2024-02-15', 8, 159.99),   -- Bike Glove L
(5, 2, '2024-03-01', 2, 89.99),    -- Helmet
(6, 3, '2024-01-25', 7, 349.99),   -- Scooter-300
(7, 3, '2024-04-20', 4, 399.99),   -- Scooter-400
(8, 4, '2024-03-10', 5, 150.00),   -- Tent
(9, 5, '2024-05-15', 3, 80.00),    -- Sleeping Bag
(10, 1, '2024-02-25', 10, 50.00),  -- Bike Water Bottle
(2, 3, '2024-06-05', 2, 299.99);   -- Bikes-200

-- Queries

-- 1. Count Categories with More than 1 Entry
SELECT CategoryID, COUNT(*)
FROM Category
GROUP BY CategoryID
HAVING COUNT(*) > 1;

-- 2. Count Products with More than 1 Entry
SELECT ProductID, COUNT(*)
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

-- 3. Count Regions with More than 1 Entry
SELECT RegionID, COUNT(*)
FROM Region
GROUP BY RegionID
HAVING COUNT(*) > 1;

-- 4. Count Countries with More than 1 Entry
SELECT CountryID, COUNT(*)
FROM Country
GROUP BY CountryID
HAVING COUNT(*) > 1;

-- 5. Count Sales with More than 1 Entry
SELECT SalesID, COUNT(*)
FROM Sales
GROUP BY SalesID
HAVING COUNT(*) > 1;

-- 6. Display Sales Information with Date Check
SELECT
    s.SalesID AS DocumentCode,
    s.SaleDate AS SaleDate,
    p.ProductName AS ProductName,
    c.CategoryName AS CategoryName,
    co.CountryName AS CountryName,
    r.RegionName AS RegionName,
    CASE
        WHEN DATEDIFF(CURDATE(), s.SaleDate) > 180 THEN TRUE
        ELSE FALSE
    END AS MoreThan180Days
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
JOIN Category c ON p.CategoryID = c.CategoryID
JOIN Region r ON s.RegionID = r.RegionID
JOIN Country co ON co.RegionID = r.RegionID;

-- 7. Find Products Sold More than Average Last Year
WITH LastYear AS (
    SELECT MAX(YEAR(SaleDate)) AS LastYear
    FROM Sales
),
AverageSalesLastYear AS (
    SELECT AVG(Quantity) AS AvgSales
    FROM Sales
    WHERE YEAR(SaleDate) = (SELECT LastYear FROM LastYear)
)
SELECT
    p.ProductID,
    SUM(s.Quantity) AS TotalQuantitySold
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
GROUP BY p.ProductID
HAVING SUM(s.Quantity) > (SELECT AvgSales FROM AverageSalesLastYear);

-- 8. Total Revenue by Product and Year
SELECT
    p.ProductID,
    YEAR(s.SaleDate) AS SaleYear,
    SUM(s.SaleAmount) AS TotalRevenue
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
GROUP BY p.ProductID, YEAR(s.SaleDate);

-- 9. Total Revenue by Country and Year
SELECT
    co.CountryName AS CountryName,
    YEAR(s.SaleDate) AS SaleYear,
    SUM(s.SaleAmount) AS TotalRevenue
FROM Sales s
JOIN Region r ON s.RegionID = r.RegionID
JOIN Country co ON co.RegionID = r.RegionID
GROUP BY co.CountryName, YEAR(s.SaleDate)
ORDER BY SaleYear, TotalRevenue DESC;

-- 10. Category with Highest Total Quantity Sold
SELECT
    c.CategoryName,
    SUM(s.Quantity) AS TotalQuantitySold
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
JOIN Category c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY TotalQuantitySold DESC
LIMIT 1;

-- 11. Products Not Sold
SELECT
    p.ProductID,
    p.ProductName
FROM Product p
LEFT JOIN Sales s ON p.ProductID = s.ProductID
WHERE s.SalesID IS NULL;

-- 12. Create View of Products with Categories
CREATE VIEW ProductView AS
SELECT
    p.ProductID,
    p.ProductName,
    c.CategoryName
FROM Product p
JOIN Category c ON p.CategoryID = c.CategoryID;

-- 13. Create View of Geographic Information
CREATE VIEW GeographicInfo AS
SELECT
    co.CountryID,
    co.CountryName,
    r.RegionID,
    r.RegionName
FROM Country co
JOIN Region r ON co.RegionID = r.RegionID;
