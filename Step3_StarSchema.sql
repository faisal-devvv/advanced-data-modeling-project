USE mydb;

-- Add OrderDate column (needed for the star schema Time dimension)
ALTER TABLE orders ADD COLUMN OrderDate DATE DEFAULT '2026-01-15';

-- Insert sample data
INSERT INTO customers (CustomerID, FullName, ContactNumber, Email) VALUES
(1, 'Amanpreet Kaur', '9876543210', 'aman@example.com'),
(2, 'Rohit Sharma', '9123456780', 'rohit@example.com'),
(3, 'Simran Gill', '9988776655', 'simran@example.com');

INSERT INTO products (ProductID, ProductName, AmountInStock, Price, Category, Subcategory) VALUES
(1, 'Office Chair', 50, 89.99, 'Furniture', 'Chairs'),
(2, 'Laptop Stand', 120, 24.50, 'Office Supplies', 'Accessories'),
(3, 'Wireless Mouse', 200, 15.75, 'Technology', 'Accessories');

INSERT INTO deliveryaddress (AddressID, Street, PostCode, City, State, Country) VALUES
(1, '123 5th Ave', '10001', 'New York', 'New York', 'United States'),
(2, '500 Market St', '94105', 'San Francisco', 'California', 'United States'),
(3, '77 Peachtree St', '30303', 'Atlanta', 'Georgia', 'United States');

INSERT INTO shipping (ShipID, ShipDate, ShipMode, AddressID, ShipCost) VALUES
(1, '2026-01-15', 'Standard Class', 1, 12.50),
(2, '2026-01-16', 'Second Class', 2, 8.00),
(3, '2026-01-17', 'First Class', 3, 20.00);

INSERT INTO orders (OrderID, CustomerID, ProductID, ShipID, Quantity, TotalCost, OrderPriority, Discount) VALUES
(1, 1, 1, 1, 2, 179.98, 'High', 0.05),
(2, 2, 2, 2, 5, 122.50, 'Medium', 0.00),
(3, 3, 3, 3, 3, 47.25, 'Low', 0.10);

-- Star schema tables
CREATE TABLE DimTime (
    TimeKey INT AUTO_INCREMENT PRIMARY KEY,
    FullDate DATE, Year INT, Quarter VARCHAR(45), Month INT, Event VARCHAR(255)
);
CREATE TABLE DimLocation (
    LocationKey INT AUTO_INCREMENT PRIMARY KEY,
    Continent VARCHAR(45), Country VARCHAR(45), City VARCHAR(45)
);
CREATE TABLE DimProducts (
    ProductKey INT AUTO_INCREMENT PRIMARY KEY,
    ProductName VARCHAR(255), Category VARCHAR(45), Subcategory VARCHAR(45), Description VARCHAR(255)
);
CREATE TABLE Sales (
    SalesKey INT AUTO_INCREMENT PRIMARY KEY,
    Price DECIMAL(10,2), Cost DECIMAL(10,2), Shipping DECIMAL(10,2), Quantity INT,
    LocationKey INT, ProductKey INT, TimeKey INT,
    FOREIGN KEY (LocationKey) REFERENCES DimLocation(LocationKey),
    FOREIGN KEY (ProductKey) REFERENCES DimProducts(ProductKey),
    FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey)
);

-- Populate star schema from the normalized data (ETL)
INSERT INTO DimTime (FullDate, Year, Quarter, Month, Event)
SELECT DISTINCT OrderDate, YEAR(OrderDate), CONCAT('Q', QUARTER(OrderDate)), MONTH(OrderDate), NULL FROM orders;

INSERT INTO DimLocation (Continent, Country, City)
SELECT DISTINCT 'North America', Country, City FROM deliveryaddress;

INSERT INTO DimProducts (ProductName, Category, Subcategory, Description)
SELECT ProductName, Category, Subcategory, NULL FROM products;

INSERT INTO Sales (Price, Cost, Shipping, Quantity, LocationKey, ProductKey, TimeKey)
SELECT p.Price, o.TotalCost, s.ShipCost, o.Quantity, dl.LocationKey, dp.ProductKey, dt.TimeKey
FROM orders o
JOIN products p ON o.ProductID = p.ProductID
JOIN shipping s ON o.ShipID = s.ShipID
JOIN deliveryaddress da ON s.AddressID = da.AddressID
JOIN DimLocation dl ON dl.City = da.City AND dl.Country = da.Country
JOIN DimProducts dp ON dp.ProductName = p.ProductName
JOIN DimTime dt ON dt.FullDate = o.OrderDate;

-- Verify
SELECT f.SalesKey, dp.ProductName, dl.City, dt.FullDate, f.Quantity, f.Price
FROM Sales f
JOIN DimProducts dp ON f.ProductKey = dp.ProductKey
JOIN DimLocation dl ON f.LocationKey = dl.LocationKey
JOIN DimTime dt ON f.TimeKey = dt.TimeKey;