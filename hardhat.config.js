require('@nomicfoundation/hardhat-toolbox')
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
        details: { yul: false },
      },
    },
  },
  networks: {
    sepolia: {
      url: 'https://rpc2.sepolia.org',
      accounts: [process.env.PRIVATE_KEY],
      oracle: '0x649a2C205BE7A3d5e99206CEEFF30c794f0E31EC',
      subid: process.env.SEPOLIA_SUB_ID,
    },
    hyperspace: {
      chainId: 3141,
      url: 'https://api.hyperspace.node.glif.io/rpc/v1',
      accounts: [process.env.PRIVATE_KEY],
    },
    mumbai: {
      url: process.env.MUMBAI_RPC,
      accounts: [process.env.PRIVATE_KEY],
    },
    polygon: {
      url: process.env.POLYGON_RPC,
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY,
      polygonMumbai: process.env.POLYGONSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
    },
  },
}
