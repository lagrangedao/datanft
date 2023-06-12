const fs = require('fs')
const { ethers, network } = require('hardhat')

async function main() {
  // const deployer = await ethers.getSigner()
  // console.log('deployer: ', deployer.address)

  const source = fs.readFileSync('./test-source.js').toString()
  const factoryAddress = ''

  console.log('updating...')
  const nftFactory = await ethers.getContractFactory('Test')
  const nftContract = nftFactory.attach(factoryAddress)

  let tx = await nftContract.updateSource(source)
  console.log(tx.hash)
  await tx.wait()
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
