-- CS4400: Introduction to Database Systems (Summer 2021)
-- Phase II: Create Table & Insert Statements

-- Team 13 - 2021-07-06
--   Que Le          (qphuong3)


-- ------------------------------------------------------
-- Schema `groceries_express`
-- ------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `groceries_express`;
USE `groceries_express`;


-- ------------------------------------------------------
-- Table `user`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `user` (
    `uname` VARCHAR(40) NOT NULL,
    `fname` VARCHAR(100) NOT NULL,
    `lname` VARCHAR(100) NOT NULL,
    `address` VARCHAR(500) NOT NULL,
    `birthdate` DATE,
    PRIMARY KEY (`uname`)
);

INSERT INTO `user` VALUES 
	('awilson5', 'Aaron', 'Wilson', '220 Peachtree Street', '1963-11-11'),
	('csoares8', 'Claire', 'Soares', '706 Living Stone Way', '1965-09-03'),
	('echarles19', 'Ella', 'Charles', '22 Peachtree Street', '1974-05-06'),
	('eross10', 'Erica', 'Ross', '22 Peachtree Street', '1975-04-02'),
	('hstark16', 'Harmon', 'Stark', '53 Tanker Top Lane', '1971-10-27'),
	('jstone5', 'Jared', 'Stone', '101 Five Finger Way', '1961-01-06'),
	('lrodriguez5', 'Lina', 'Rodriguez', '360 Corkscrew Circle', '1975-04-02'),
	('sprince6', 'Sarah', 'Prince', '22 Peachtree Street', '1968-06-15'),
	('tmccall5', 'Trey', 'McCall', '360 Corkscrew Circle', '1973-03-19');


-- ------------------------------------------------------
-- Table `customer`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `customer` (
    `uname` VARCHAR(40) NOT NULL,
    `credit` INT NOT NULL,
    `rating` TINYINT DEFAULT 1,
    PRIMARY KEY (`uname`),
    FOREIGN KEY (`uname`)
        REFERENCES `user` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `customer` VALUES 
	('awilson5', 100, 2),
	('jstone5', 40, 4),
	('lrodriguez5', 60, 4),
	('sprince6', 30, 5);


-- ------------------------------------------------------
-- Table `employee`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `employee` (
    `uname` VARCHAR(40) NOT NULL,
    `taxID` CHAR(9) NOT NULL,
    `hired` DATE,
    `service` SMALLINT UNSIGNED,
    `salary` DECIMAL(12 , 2),
    PRIMARY KEY (`uname`),
    UNIQUE (`taxID`),
    FOREIGN KEY (`uname`)
        REFERENCES `user` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `employee` VALUES 
	('awilson5', '111111111', '2020-03-15', 9, 46000),
	('csoares8', '888888888', '2019-02-25', 26, 57000),
	('echarles19', '777777777', '2021-01-02', 3, 27000),
	('eross10', '444444444', '2020-04-17', 10, 61000),
	('hstark16', '555555555', '2018-07-23', 20, 59000),
	('lrodriguez5', '222222222', '2019-04-15', 20, 58000),
	('tmccall5', '333333333', '2018-10-17', 29, 33000);


-- ------------------------------------------------------
-- Table `floor_worker`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `floor_worker` (
    `uname` VARCHAR(40) NOT NULL,
    PRIMARY KEY (`uname`),
    FOREIGN KEY (`uname`)
        REFERENCES `employee` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `floor_worker` VALUES 
	('hstark16'),
	('eross10'),
	('echarles19');


-- ------------------------------------------------------
-- Table `store`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `store` (
    `storeID` VARCHAR(40),
    `sname` VARCHAR(100),
    `revenue` DECIMAL(15 , 2),
    `manage` VARCHAR(40),
    PRIMARY KEY (`storeID`),
    FOREIGN KEY (`manage`)
        REFERENCES `floor_worker` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `store` VALUES 
	('pub', 'Publix', 200, 'hstark16'),
    ('krg', 'Kroger', 300, 'echarles19');


-- ------------------------------------------------------
-- Table `drone_pilot`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `drone_pilot` (
    `uname` VARCHAR(40) NOT NULL,
    `licenceID` VARCHAR(40),
    `experience` INT UNSIGNED DEFAULT 0,
    PRIMARY KEY (`uname`),
    FOREIGN KEY (`uname`)
        REFERENCES `employee` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `drone_pilot` VALUES 
	('awilson5', '314159', 41),
    ('tmccall5', '181633', 10),
	('lrodriguez5', '287182', 67);


-- ------------------------------------------------------
-- Table `drone`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `drone` (
    `storeID` VARCHAR(40) NOT NULL,
    `droneTag` INT UNSIGNED NOT NULL,
    `rem_trips` TINYINT UNSIGNED,
    `capacity` SMALLINT UNSIGNED,
    `control` VARCHAR(40) NOT NULL,
    PRIMARY KEY (`storeID` , `droneTag`),
    FOREIGN KEY (`storeID`)
        REFERENCES `store` (`storeID`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`control`)
        REFERENCES `drone_pilot` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE
    CHECK (
        capacity >= (
            SELECT SUM(i.weight * c.quantity)
            FROM `contain` c
            JOIN `item` i ON c.barcode = i.barcode
            JOIN `order` o ON c.orderID = o.orderID
            WHERE o.storeID = `drone`.`storeID`
            AND o.droneTag = `drone`.`droneTag`
        )
    )
);

ALTER TABLE `drone` ADD CONSTRAINT `unique_drone_control` UNIQUE (`control`);

INSERT INTO `drone` VALUES 
	('pub', 1, 3, 10, 'awilson5'),
    ('pub', 2, 2, 20, 'tmccall5'),
	('krg', 1, 4, 15, 'lrodriguez5');


-- ------------------------------------------------------
-- Table `order`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order` (
    `orderID` VARCHAR(40) NOT NULL,
    `sold_on` DATE,
    `request` VARCHAR(40) NOT NULL,
    `storeID` VARCHAR(40),
    `droneTag` INT UNSIGNED NOT NULL,
    PRIMARY KEY (`orderID`),
    FOREIGN KEY (`request`)
        REFERENCES `customer` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`storeID` , `droneTag`)
        REFERENCES `drone` (`storeID` , `droneTag`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `order` VALUES
    ('pub_303', '2021-05-23', 'sprince6', 'pub', 1),
	('pub_306', '2021-05-22', 'awilson5', 'pub', 2),
	('pub_305', '2021-05-22', 'sprince6', 'pub', 2),
    ('krg_217', '2021-05-23', 'jstone5', 'krg', 1);


-- ------------------------------------------------------
-- Table `item`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `item` (
    `barcode` VARCHAR(40) NOT NULL,
    `iname` VARCHAR(100) NOT NULL,
    `weight` SMALLINT UNSIGNED,
    PRIMARY KEY (`barcode`)
);

INSERT INTO `item` VALUES 
	('ap_9T25E36L', 'antipasto platter', 4),
	('pr_3C6A9R', 'pot roast', 6),
	('hs_5E7L23M', 'hoagie sandwich', 3),
	('clc_4T9U25X', 'chocolate lava cake', 5),
	('ss_2D4E6L', 'shrimp salad', 3);


-- ------------------------------------------------------
-- Table `employ`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `employ` (
    `uname` VARCHAR(40) NOT NULL,
    `storeID` VARCHAR(40) NOT NULL,
    PRIMARY KEY (`uname` , `storeID`),
    FOREIGN KEY (`uname`)
        REFERENCES `floor_worker` (`uname`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`storeID`)
        REFERENCES `store` (`storeID`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `employ` VALUES
    ('echarles19', 'krg'),
	('eross10', 'pub'),
	('eross10', 'krg'),
    ('hstark16', 'pub');


-- ------------------------------------------------------
-- Table `contain`
-- ------------------------------------------------------
CREATE TABLE IF NOT EXISTS `contain` (
    `orderID` VARCHAR(40) NOT NULL,
    `barcode` VARCHAR(40) NOT NULL,
    `price` DECIMAL(12, 2),
    `quantity` INT UNSIGNED,
    PRIMARY KEY (`orderID` , `barcode`),
    FOREIGN KEY (`orderID`)
        REFERENCES `order` (`orderID`)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (`barcode`)
        REFERENCES `item` (`barcode`)
        ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `contain` VALUES
    ('pub_303', 'ap_9T25E36L', 4, 1),
    ('pub_303', 'pr_3C6A9R', 20, 1),
	('pub_306', 'hs_5E7L23M', 3, 2),
	('pub_306', 'ap_9T25E36L', 10, 1),
	('pub_305', 'clc_4T9U25X', 3, 2),
    ('krg_217', 'pr_3C6A9R', 15, 2);
