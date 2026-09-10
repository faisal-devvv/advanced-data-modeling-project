-- =====================================================
-- Step 3: Star schema for Global Super Store
-- PART A = MySQL Workbench Forward Engineering output
--          (generated from the star-schema EER diagram:
--           sales + dimtime + dimlocation + dimproducts)
-- PART B = hand-written ETL + verification
-- Run AFTER create_database.sql (+ its sample load).
-- =====================================================

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

USE `mydb` ;

-- -----------------------------------------------------
-- PART A — Forward-engineered DDL (matches star diagram 1:1)
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`dimtime` (
  `TimeKey`  INT  NOT NULL AUTO_INCREMENT,
  `FullDate` DATE NULL,
  `Year`     INT  NULL,
  `Quarter`  VARCHAR(45) NULL,
  `Month`    INT  NULL,
  `Day`      INT  NULL,
  PRIMARY KEY (`TimeKey`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`dimlocation` (
  `LocationKey` INT NOT NULL AUTO_INCREMENT,
  `Address_ID`  INT NULL,
  `Postal_Code` VARCHAR(20)  NULL,
  `City`        VARCHAR(100) NULL,
  `State`       VARCHAR(100) NULL,
  `Country`     VARCHAR(100) NULL,
  `Region`      VARCHAR(50)  NULL,
  `Market`      VARCHAR(50)  NULL,
  PRIMARY KEY (`LocationKey`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`dimproducts` (
  `ProductKey` INT NOT NULL AUTO_INCREMENT,
  `Product_ID` VARCHAR(50)  NULL,
  `ProductName` VARCHAR(255) NULL,
  `Category`   VARCHAR(50)  NULL,
  `Sub_Category` VARCHAR(50) NULL,
  PRIMARY KEY (`ProductKey`))
ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS `mydb`.`sales` (
  `SalesKey`      INT NOT NULL AUTO_INCREMENT,
  `Row_ID`        INT NULL,
  `Order_ID`      VARCHAR(50) NULL,
  `Sales`         DECIMAL(12,5) NULL,
  `Profit`        DECIMAL(12,5) NULL,
  `Discount`      DECIMAL(4,3)  NULL,
  `Shipping_Cost` DECIMAL(10,2) NULL,
  `Quantity`      INT NULL,
  `LocationKey`   INT NOT NULL,
  `ProductKey`    INT NOT NULL,
  `TimeKey`       INT NOT NULL,
  PRIMARY KEY (`SalesKey`),
  INDEX `fk_sales_dimlocation_idx` (`LocationKey` ASC) VISIBLE,
  INDEX `fk_sales_dimproducts_idx` (`ProductKey` ASC) VISIBLE,
  INDEX `fk_sales_dimtime_idx` (`TimeKey` ASC) VISIBLE,
  CONSTRAINT `fk_sales_dimlocation`
    FOREIGN KEY (`LocationKey`)
    REFERENCES `mydb`.`dimlocation` (`LocationKey`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sales_dimproducts`
    FOREIGN KEY (`ProductKey`)
    REFERENCES `mydb`.`dimproducts` (`ProductKey`)
    ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sales_dimtime`
    FOREIGN KEY (`TimeKey`)
    REFERENCES `mydb`.`dimtime` (`TimeKey`)
    ON DELETE NO ACTION ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- PART B — Hand-written ETL (extract → transform → load)
-- -----------------------------------------------------
-- B1. Time dimension from order dates
INSERT INTO dimtime (FullDate, Year, Quarter, Month, Day)
SELECT DISTINCT Order_Date, YEAR(Order_Date),
       CONCAT('Q', QUARTER(Order_Date)), MONTH(Order_Date), DAY(Order_Date)
FROM orders;

-- B2. Location dimension (keeps Address_ID as lineage to deliveryaddress)
INSERT INTO dimlocation (Address_ID, Postal_Code, City, State, Country, Region, Market)
SELECT Address_ID, Postal_Code, City, State, Country, Region, Market
FROM deliveryaddress;

-- B3. Product dimension (keeps Product_ID as lineage to products)
INSERT INTO dimproducts (Product_ID, ProductName, Category, Sub_Category)
SELECT Product_ID, Product_Name, Category, Sub_Category
FROM products;

-- B4. Fact table: measures from orders+shipping, keys via exact joins
INSERT INTO sales (Row_ID, Order_ID, Sales, Profit, Discount, Shipping_Cost,
                   Quantity, LocationKey, ProductKey, TimeKey)
SELECT o.Row_ID, o.Order_ID, o.Sales, o.Profit, o.Discount, s.Shipping_Cost,
       o.Quantity, dl.LocationKey, dp.ProductKey, dt.TimeKey
FROM orders o
JOIN shipping s         ON o.Ship_ID    = s.Ship_ID
JOIN deliveryaddress da ON s.Address_ID = da.Address_ID
JOIN dimlocation dl     ON dl.Address_ID = da.Address_ID
JOIN products p         ON o.Product_ID = p.Product_ID
JOIN dimproducts dp     ON dp.Product_ID = p.Product_ID
JOIN dimtime dt         ON dt.FullDate  = o.Order_Date;

-- -----------------------------------------------------
-- PART B5 — Verification queries
-- -----------------------------------------------------
-- V1: fact joined back through all three dimensions
SELECT s.SalesKey, s.Order_ID, dt.FullDate, dl.Country, dl.State,
       dp.ProductName, s.Quantity, s.Sales, s.Profit, s.Discount, s.Shipping_Cost
FROM sales s
JOIN dimtime dt     ON s.TimeKey     = dt.TimeKey
JOIN dimlocation dl ON s.LocationKey = dl.LocationKey
JOIN dimproducts dp ON s.ProductKey  = dp.ProductKey
ORDER BY s.SalesKey;

-- V2: dimensional analysis (works = star schema is queryable)
SELECT dl.Market, SUM(s.Sales) AS TotalSales, SUM(s.Profit) AS TotalProfit,
       SUM(s.Shipping_Cost) AS TotalShipping
FROM sales s JOIN dimlocation dl ON s.LocationKey = dl.LocationKey
GROUP BY dl.Market;

-- V3: reconciliation — star totals must equal normalized totals
SELECT (SELECT SUM(Sales) FROM sales)  AS StarSales,
       (SELECT SUM(Sales) FROM orders) AS NormalizedSales;