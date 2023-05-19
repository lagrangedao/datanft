-- ----------------------------
-- Table structure for factory_contract_details
-- ----------------------------
DROP TABLE IF EXISTS `factory_contract_details`;
CREATE TABLE `factory_contract_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chain_id` varchar(10) COLLATE utf8_bin NOT NULL,
  `last_scan_block` int(11) NOT NULL,
  `factory_contract_address` varchar(100) COLLATE utf8_bin NOT NULL,
  `owner` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `rpc_url` varchar(255) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

SET FOREIGN_KEY_CHECKS = 1;



-- ----------------------------
-- Table structure for nft_factory_transactions
-- ----------------------------
DROP TABLE IF EXISTS `nft_factory_transactions`;
CREATE TABLE `nft_factory_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chain_id` varchar(10) COLLATE utf8_bin NOT NULL,
  `dataset_name` varchar(100) COLLATE utf8_bin NOT NULL,
  `data_NFT_address` varchar(100) COLLATE utf8_bin NOT NULL,
  `owner` varchar(100) COLLATE utf8_bin NOT NULL,
  `transaction_hash` varchar(200) COLLATE utf8_bin NOT NULL,
  `contract_address` varchar(100) COLLATE utf8_bin NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

SET FOREIGN_KEY_CHECKS = 1;



