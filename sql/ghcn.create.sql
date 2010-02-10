SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `ghcn` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `ghcn`;

-- -----------------------------------------------------
-- Table `ghcn`.`region`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ghcn`.`region` ;

CREATE  TABLE IF NOT EXISTS `ghcn`.`region` (
  `id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ghcn`.`country`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ghcn`.`country` ;

CREATE  TABLE IF NOT EXISTS `ghcn`.`country` (
  `id` INT UNSIGNED NOT NULL ,
  `id_region` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_country_region` (`id_region` ASC) ,
  CONSTRAINT `fk_country_region`
    FOREIGN KEY (`id_region` )
    REFERENCES `ghcn`.`region` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ghcn`.`station`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ghcn`.`station` ;

CREATE  TABLE IF NOT EXISTS `ghcn`.`station` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `id_country` INT UNSIGNED NOT NULL ,
  `wmo_number` INT UNSIGNED NOT NULL ,
  `modifier` CHAR(3) NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  `latitude` FLOAT NOT NULL ,
  `longitude` FLOAT NOT NULL ,
  `elevation1` INT NULL ,
  `elevation2` INT NULL ,
  `population_assessment` CHAR(1) NULL ,
  `population` INT NULL ,
  `topography` CHAR(2) NULL ,
  `vegetatation` CHAR(2) NULL ,
  `location` CHAR(2) NULL ,
  `coast_distance` INT NULL ,
  `airport` CHAR(1) NULL ,
  `town_distance` INT NULL ,
  `temperature` INT NULL ,
  `precipitation` INT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_station_country` (`id_country` ASC) ,
  UNIQUE INDEX `idx_station_wmo_number_modifier` (`wmo_number` ASC, `modifier` ASC) ,
  CONSTRAINT `fk_station_country`
    FOREIGN KEY (`id_country` )
    REFERENCES `ghcn`.`country` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ghcn`.`data_set_type`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ghcn`.`data_set_type` ;

CREATE  TABLE IF NOT EXISTS `ghcn`.`data_set_type` (
  `id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `ghcn`.`data_set`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `ghcn`.`data_set` ;

CREATE  TABLE IF NOT EXISTS `ghcn`.`data_set` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `id_station` INT UNSIGNED NOT NULL ,
  `id_data_set_type` INT UNSIGNED NOT NULL ,
  `year` INT NOT NULL ,
  `duplicate` INT UNSIGNED NOT NULL ,
  `january` FLOAT NULL ,
  `february` FLOAT NULL ,
  `march` FLOAT NULL ,
  `april` FLOAT NULL ,
  `may` FLOAT NULL ,
  `june` FLOAT NULL ,
  `july` FLOAT NULL ,
  `august` FLOAT NULL ,
  `september` FLOAT NULL ,
  `october` FLOAT NULL ,
  `november` FLOAT NULL ,
  `december` FLOAT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_data_set_data_set_type` (`id_data_set_type` ASC) ,
  INDEX `fk_data_set_station` (`id_station` ASC) ,
  UNIQUE INDEX `idx_data_set_id_station_id_data_set_type_year_duplicate` (`id_station` ASC, `id_data_set_type` ASC, `year` ASC, `duplicate` ASC) ,
  CONSTRAINT `fk_data_set_data_set_type`
    FOREIGN KEY (`id_data_set_type` )
    REFERENCES `ghcn`.`data_set_type` (`id` )
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_data_set_station`
    FOREIGN KEY (`id_station` )
    REFERENCES `ghcn`.`station` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `ghcn`.`region`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
USE `ghcn`;
INSERT INTO `region` (`id`, `name`) VALUES (1, 'Africa');
INSERT INTO `region` (`id`, `name`) VALUES (2, 'Asia');
INSERT INTO `region` (`id`, `name`) VALUES (3, 'South America');
INSERT INTO `region` (`id`, `name`) VALUES (4, 'North & Central America');
INSERT INTO `region` (`id`, `name`) VALUES (5, 'South-West Pacific');
INSERT INTO `region` (`id`, `name`) VALUES (6, 'Europe');
INSERT INTO `region` (`id`, `name`) VALUES (7, 'Antartic');
INSERT INTO `region` (`id`, `name`) VALUES (8, 'Ship Stations');

COMMIT;

-- -----------------------------------------------------
-- Data for table `ghcn`.`data_set_type`
-- -----------------------------------------------------
SET AUTOCOMMIT=0;
USE `ghcn`;
INSERT INTO `data_set_type` (`id`, `name`) VALUES (1, 'min_temperature');
INSERT INTO `data_set_type` (`id`, `name`) VALUES (2, 'mean_temperature');
INSERT INTO `data_set_type` (`id`, `name`) VALUES (3, 'max_temperature');
INSERT INTO `data_set_type` (`id`, `name`) VALUES (4, 'precipitation');

COMMIT;
