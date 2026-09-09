-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`Customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Customers` (
  `Customer_ID` VARCHAR(50) NOT NULL,
  `Customer_Name` VARCHAR(255) NOT NULL,
  `Segment` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`Customer_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Products` (
  `Product_ID` VARCHAR(50) NOT NULL,
  `Product_Name` VARCHAR(255) NOT NULL,
  `Category` VARCHAR(50) NOT NULL,
  `Sub_Category` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`Product_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DeliveryAddress`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`DeliveryAddress` (
  `Address_ID` INT NOT NULL AUTO_INCREMENT,
  `Postal_Code` VARCHAR(20) NULL,
  `City` VARCHAR(100) NOT NULL,
  `State` VARCHAR(100) NOT NULL,
  `Country` VARCHAR(100) NOT NULL,
  `Region` VARCHAR(50) NOT NULL,
  `Market` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`Address_ID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Shipping`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Shipping` (
  `Ship_ID` INT NOT NULL AUTO_INCREMENT,
  `Ship_Date` DATE NOT NULL,
  `Ship_Mode` VARCHAR(50) NOT NULL,
  `Shipping_Cost` DECIMAL(10,2) NOT NULL,
  `Address_ID` INT NOT NULL,
  PRIMARY KEY (`Ship_ID`),
  INDEX `fk_Shipping_DeliveryAddress1_idx` (`Address_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Shipping_DeliveryAddress1`
    FOREIGN KEY (`Address_ID`)
    REFERENCES `mydb`.`DeliveryAddress` (`Address_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Orders` (
  `Row_ID` INT NOT NULL,
  `Order_ID` VARCHAR(50) NOT NULL,
  `Order_Date` DATE NOT NULL,
  `Sales` DECIMAL(12,2) NOT NULL,
  `Quantity` INT NOT NULL,
  `Discount` DECIMAL(4,2) NOT NULL,
  `Profit` DECIMAL(12,2) NOT NULL,
  `Order_Priority` VARCHAR(50) NULL,
  `Customer_ID` VARCHAR(50) NOT NULL,
  `Product_ID` VARCHAR(50) NOT NULL,
  `Ship_ID` INT NOT NULL,
  PRIMARY KEY (`Row_ID`),
  INDEX `fk_Orders_Customers_idx` (`Customer_ID` ASC) VISIBLE,
  INDEX `fk_Orders_Products1_idx` (`Product_ID` ASC) VISIBLE,
  INDEX `fk_Orders_Shipping1_idx` (`Ship_ID` ASC) VISIBLE,
  CONSTRAINT `fk_Orders_Customers`
    FOREIGN KEY (`Customer_ID`)
    REFERENCES `mydb`.`Customers` (`Customer_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Products1`
    FOREIGN KEY (`Product_ID`)
    REFERENCES `mydb`.`Products` (`Product_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Orders_Shipping1`
    FOREIGN KEY (`Ship_ID`)
    REFERENCES `mydb`.`Shipping` (`Ship_ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;