-- -----------------------------------------------------
-- MySQL Workbench Forward Engineering
-- Global Super Store — normalized schema
-- Implements er_diagram.png exactly (customers, products,
-- deliveryaddress, shipping, orders)
-- -----------------------------------------------------

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8mb4 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`customers` (
  `Customer_ID`   VARCHAR(50)  NOT NULL,
  `Customer_Name` VARCHAR(255) NULL,
  `Segment`       VARCHAR(50)  NULL,
  PRIMARY KEY (`Customer_ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`products` (
  `Product_ID`   VARCHAR(50)  NOT NULL,
  `Product_Name` VARCHAR(255) NULL,
  `Category`     VARCHAR(50)  NULL,
  `Sub_Category` VARCHAR(50)  NULL,
  PRIMARY KEY (`Product_ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`deliveryaddress`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`deliveryaddress` (
  `Address_ID`  INT          NOT NULL AUTO_INCREMENT,
  `Postal_Code` VARCHAR(20)  NULL,
  `City`        VARCHAR(100) NULL,
  `State`       VARCHAR(100) NULL,
  `Country`     VARCHAR(100) NULL,
  `Region`      VARCHAR(50)  NULL,
  `Market`      VARCHAR(50)  NULL,
  PRIMARY KEY (`Address_ID`))
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`shipping`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`shipping` (
  `Ship_ID`       INT           NOT NULL AUTO_INCREMENT,
  `Ship_Date`     DATE          NULL,
  `Ship_Mode`     VARCHAR(50)   NULL,
  `Shipping_Cost` DECIMAL(10,2) NULL,
  `Address_ID`    INT           NOT NULL,
  PRIMARY KEY (`Ship_ID`),
  INDEX `fk_shipping_deliveryaddress1_idx` (`Address_ID` ASC) VISIBLE,
  CONSTRAINT `fk_shipping_deliveryaddress1`
    FOREIGN KEY (`Address_ID`)
    REFERENCES `mydb`.`deliveryaddress` (`Address_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- -----------------------------------------------------
-- Table `mydb`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`orders` (
  `Row_ID`         INT            NOT NULL,
  `Order_ID`       VARCHAR(50)    NULL,
  `Order_Date`     DATE           NULL,
  `Sales`          DECIMAL(12,5)  NULL,
  `Quantity`       INT            NULL,
  `Discount`       DECIMAL(4,3)   NULL,
  `Profit`         DECIMAL(12,5)  NULL,
  `Order_Priority` VARCHAR(50)    NULL,
  `Customer_ID`    VARCHAR(50)    NOT NULL,
  `Product_ID`     VARCHAR(50)    NOT NULL,
  `Ship_ID`        INT            NOT NULL,
  PRIMARY KEY (`Row_ID`),
  INDEX `fk_orders_customers_idx` (`Customer_ID` ASC) VISIBLE,
  INDEX `fk_orders_products1_idx` (`Product_ID` ASC) VISIBLE,
  INDEX `fk_orders_shipping1_idx` (`Ship_ID` ASC) VISIBLE,
  CONSTRAINT `fk_orders_customers`
    FOREIGN KEY (`Customer_ID`)
    REFERENCES `mydb`.`customers` (`Customer_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_products1`
    FOREIGN KEY (`Product_ID`)
    REFERENCES `mydb`.`products` (`Product_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_orders_shipping1`
    FOREIGN KEY (`Ship_ID`)
    REFERENCES `mydb`.`shipping` (`Ship_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;