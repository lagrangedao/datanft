require('dotenv').config()
const Web3 = require('web3')
const FEVM_HYPERSPACE_URL = 'https://api.hyperspace.node.glif.io/rpc/v1'
const FACTORY_ABI = require('../DataNFTFactory.json')

async function main() {
  // connect web3
  const web3 = new Web3(FEVM_HYPERSPACE_URL)

  // attach wallet
  web3.eth.accounts.wallet.add(process.env.PRIVATE_KEY)
  let caller = web3.eth.accounts.privateKeyToAccount(process.env.PRIVATE_KEY)
    .address

  // connect contract address + abi
  const factory = new web3.eth.Contract(
    FACTORY_ABI,
    '0x93C2aB6d92b3d40DEcf3eaFEA2B8b539EE78738e',
  )

  // dataset name and uri from lagrange
  let datasetName = 'dataset123'
  let uri = 'ipfs.io/ipfs/Qm...'

  // estimate gas
  let estimatedGas = await factory.methods
    .claimDataNFT(datasetName, uri)
    .estimateGas({ from: caller })

  // we will use estimated gas * 1.5
  let gasLimit = Math.floor(estimatedGas * 1.5)

  console.log('estimated gas:', estimatedGas)
  console.log('gas limit:', gasLimit)

  // call contract
  console.log('Deploying Data NFT...')
  const tx = await factory.methods
    .claimDataNFT(datasetName, uri)
    .send({ from: caller, gasLimit: gasLimit })

  // display results
  console.log('tx hash:', tx.transactionHash)

  let eventArgs = tx.events.CreateDataNFT.returnValues
  console.log('owner:', eventArgs.owner)
  console.log('dataset name:', eventArgs.datasetName)
  console.log('dataNFT address:', eventArgs.dataNFTAddress)
}
main()
