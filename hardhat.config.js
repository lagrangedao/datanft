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
    hyperspace: {
      chainId: 3141,
      url: 'https://api.hyperspace.node.glif.io/rpc/v1',
      accounts: [process.env.PRIVATE_KEY],
    },
  },
}
