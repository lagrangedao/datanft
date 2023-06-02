const fs = require('fs')
const { ethers, network } = require('hardhat')

async function main() {
  // const deployer = await ethers.getSigner()
  // console.log('deployer: ', deployer.address)

  const subID = network.config.subid
  const source = fs.readFileSync('./functions-source.js').toString()
  const sepoliaOracle = network.config.oracle

  console.log('deploying...')
  const nftFactory = await ethers.getContractFactory('DataNFTFactory')
  const nftContract = await nftFactory.deploy(sepoliaOracle, subID, source)

  console.log('address: ' + nftContract.address)
  await nftContract.deployed()

  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms))
  }
  await sleep(20000)

  console.log('verifying...')
  await hre.run('verify:verify', {
    address: nftContract.address,
    constructorArguments: [sepoliaOracle, subID, source],
  })
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
