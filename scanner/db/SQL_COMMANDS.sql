-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema nft_factory_data
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema nft_factory_data
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `nft_factory_data` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `nft_factory_data` ;

-- -----------------------------------------------------
-- Table `nft_factory_data`.`factory_contract_details`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `nft_factory_data`.`factory_contract_details` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `last_scan_block` INT NOT NULL,
  `factory_contract_address` VARCHAR(100) NOT NULL,
  `owner` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `nft_factory_data`.`nft_factory_transactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `nft_factory_data`.`nft_factory_transactions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `dataset_name` VARCHAR(100) NOT NULL,
  `data_NFT_address` VARCHAR(100) NOT NULL,
  `owner` VARCHAR(100) NOT NULL,
  `transaction_hash` VARCHAR(200) NOT NULL,
  `contract_address` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
