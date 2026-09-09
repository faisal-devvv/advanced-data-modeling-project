USE mydb;

-- Representative sample rows (values in real Global Superstore format)
INSERT INTO Customers (Customer_ID, Customer_Name, Segment) VALUES
('CG-12520', 'Amanpreet Kaur', 'Consumer'),
('RO-19870', 'Rohit Sharma',  'Corporate'),
('SI-20930', 'Simran Gill',   'Home Office');

INSERT INTO Products (Product_ID, Product_Name, Category, Sub_Category) VALUES
('FUR-CH-10000454', 'Office Chair',   'Furniture',       'Chairs'),
('OFF-AC-10000178', 'Laptop Stand',   'Office Supplies', 'Accessories'),
('TEC-AC-10000387', 'Wireless Mouse', 'Technology',      'Accessories');

INSERT INTO DeliveryAddress (Postal_Code, City, State, Country, Region, Market) VALUES
('10001', 'New York',      'New York',   'United States', 'East',  'US'),
('94105', 'San Francisco', 'California', 'United States', 'West',  'US'),
('30303', 'Atlanta',       'Georgia',    'United States', 'South', 'US');

INSERT INTO Shipping (Ship_Date, Ship_Mode, Shipping_Cost, Address_ID) VALUES
('2024-01-15', 'Standard Class', 12.50, 1),
('2024-01-16', 'Second Class',   8.00,  2),
('2024-01-17', 'First Class',    20.00, 3);

INSERT INTO Orders (Row_ID, Order_ID, Order_Date, Sales, Quantity, Discount, Profit, Order_Priority, Customer_ID, Product_ID, Ship_ID) VALUES
(1, 'CA-2024-100001', '2024-01-12', 179.98, 2, 0.05, 32.40, 'High',   'CG-12520', 'FUR-CH-10000454', 1),
(2, 'CA-2024-100002', '2024-01-13', 122.50, 5, 0.00, 38.10, 'Medium', 'RO-19870', 'OFF-AC-10000178', 2),
(3, 'CA-2024-100003', '2024-01-14',  47.25, 3, 0.10,  9.60, 'Low',    'SI-20930', 'TEC-AC-10000387', 3);

-- Star schema
CREATE TABLE DimTime (
  TimeKey  INT NOT NULL AUTO_INCREMENT,
  FullDate DATE NOT NULL,
  Year     INT NOT NULL,
  Quarter  VARCHAR(2) NOT NULL,
  Month    INT NOT NULL,
  Day      INT NOT NULL,
  PRIMARY KEY (TimeKey), UNIQUE KEY uq_dimtime (FullDate));

CREATE TABLE DimLocation (
  LocationKey INT NOT NULL AUTO_INCREMENT,
  Address_ID  INT NOT NULL,
  Postal_Code VARCHAR(20) NULL,
  City        VARCHAR(100) NOT NULL,
  State       VARCHAR(100) NOT NULL,
  Country     VARCHAR(100) NOT NULL,
  Region      VARCHAR(50) NOT NULL,
  Market      VARCHAR(50) NOT NULL,
  PRIMARY KEY (LocationKey), UNIQUE KEY uq_dimloc (Address_ID));

CREATE TABLE DimProducts (
  ProductKey   INT NOT NULL AUTO_INCREMENT,
  Product_ID   VARCHAR(50) NOT NULL,
  ProductName  VARCHAR(255) NOT NULL,
  Category     VARCHAR(50) NOT NULL,
  Sub_Category VARCHAR(50) NOT NULL,
  PRIMARY KEY (ProductKey), UNIQUE KEY uq_dimprod (Product_ID));

CREATE TABLE Sales (
  SalesKey      INT NOT NULL AUTO_INCREMENT,
  Row_ID        INT NOT NULL,
  Order_ID      VARCHAR(50) NOT NULL,
  Sales         DECIMAL(12,2) NOT NULL,
  Profit        DECIMAL(12,2) NOT NULL,
  Discount      DECIMAL(4,2) NOT NULL,
  Shipping_Cost DECIMAL(10,2) NOT NULL,
  Quantity      INT NOT NULL,
  LocationKey   INT NOT NULL,
  ProductKey    INT NOT NULL,
  TimeKey       INT NOT NULL,
  PRIMARY KEY (SalesKey), UNIQUE KEY uq_sales_row (Row_ID),
  CONSTRAINT fk_sales_location FOREIGN KEY (LocationKey) REFERENCES DimLocation (LocationKey),
  CONSTRAINT fk_sales_product  FOREIGN KEY (ProductKey)  REFERENCES DimProducts (ProductKey),
  CONSTRAINT fk_sales_time     FOREIGN KEY (TimeKey)     REFERENCES DimTime (TimeKey));

-- ETL: normalized -> star
INSERT INTO DimTime (FullDate, Year, Quarter, Month, Day)
SELECT DISTINCT Order_Date, YEAR(Order_Date), CONCAT('Q', QUARTER(Order_Date)), MONTH(Order_Date), DAY(Order_Date)
FROM Orders;

INSERT INTO DimLocation (Address_ID, Postal_Code, City, State, Country, Region, Market)
SELECT Address_ID, Postal_Code, City, State, Country, Region, Market FROM DeliveryAddress;

INSERT INTO DimProducts (Product_ID, ProductName, Category, Sub_Category)
SELECT Product_ID, Product_Name, Category, Sub_Category FROM Products;

INSERT INTO Sales (Row_ID, Order_ID, Sales, Profit, Discount, Shipping_Cost, Quantity, LocationKey, ProductKey, TimeKey)
SELECT o.Row_ID, o.Order_ID, o.Sales, o.Profit, o.Discount, sh.Shipping_Cost, o.Quantity,
       dl.LocationKey, dp.ProductKey, dt.TimeKey
FROM Orders o
JOIN Shipping sh    ON sh.Ship_ID = o.Ship_ID
JOIN DimLocation dl ON dl.Address_ID = sh.Address_ID
JOIN DimProducts dp ON dp.Product_ID = o.Product_ID
JOIN DimTime dt     ON dt.FullDate = o.Order_Date;

-- Verification (screenshot this grid -> star_schema_verification.jpg)
SELECT f.SalesKey, f.Order_ID, dt.FullDate, dl.Country, dl.Region, dl.Market,
       dp.Category, dp.ProductName, f.Quantity, f.Sales, f.Profit
FROM Sales f
JOIN DimTime dt     ON f.TimeKey = dt.TimeKey
JOIN DimLocation dl ON f.LocationKey = dl.LocationKey
JOIN DimProducts dp ON f.ProductKey = dp.ProductKey
ORDER BY f.SalesKey;