from web3 import Web3
from web3.middleware import geth_poa_middleware
from web3.contract import ContractEvent
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from hexbytes import HexBytes
from model.nft_factory_data import NFTFactoryTransactions,FactoryContractDetails
from model import db

import time
import mysql.connector
import json
import warnings
import logging
import toml

# set up logging to file
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M')
# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)
# add the handler to the root logger
logging.getLogger('').addHandler(console)

config=toml.load('config.toml')
rpc_url = config['rpc_endpoint']

class NFTScanner:
    def __init__(self, nft_factory_contract_address):
        # Data NFT with Chainlink functions contract address
        self.nft_factory_contract_address = nft_factory_contract_address

        # Data NFT with Chainlink functions contract ABI
        self.nft_factory_abi_file_path = '../contracts/abi/DataNFTFactory.json'

        # DB connection
        self.engine = create_engine('mysql+mysqlconnector://' + config['DB_USER'] + ':' + config['DB_PASSWORD'] + '@localhost/nft_factory_data')
        Session = sessionmaker(bind=self.engine)
        self.session = Session()

        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.w3.middleware_onion.inject(geth_poa_middleware, layer=0)
        self.nft_factory_abi = json.load(open(self.nft_factory_abi_file_path))
        
        try:
            lastScannedBlock = self.session.query(FactoryContractDetails.last_scan_block).first()
        except Exception as e:
            logging.error("Error fetching the last_scan_block: ",e)
        finally:
            self.session.close()

        if lastScannedBlock:
            self.from_block = lastScannedBlock[0] + 1
        else:
            # Block at which the fatory contract was deployed
            self.from_block = 353737

        self.batch_size = 1000

    # Function to update the ownership of the NFT or insert a newly minted NFT
    def insert_nft_contract_deails(self, _datasetName, _dataNFTaddress, _owner, _transactionhash, _contractAddress):
        try:
            Session = sessionmaker(bind=self.engine)
            self.session = Session()
        except Exception as e:
            logging.error("Error creating a new session: ",e)

        try:
            # Insert new NFT details
            nft_contract_tx = NFTFactoryTransactions(
                dataset_name= _datasetName,
                data_NFT_address= _dataNFTaddress,
                owner=_owner,
                transaction_hash=_transactionhash,
                contract_address=_contractAddress
            )

            self.session.add(nft_contract_tx)
            self.session.commit()
            return True
        except Exception as e:
            logging.error("Error updating NFT ownership: ", e)
            return False
        finally:
            self.session.close()

    def start_NFT_scan(self, target_block):
        while self.from_block < target_block:
            warnings.filterwarnings("ignore")

            to_block = self.from_block + self.batch_size
            # logging.info(f"scanning from {self.from_block} to {target_block}")

            nft_factory_contract = self.w3.eth.contract(address=Web3.toChecksumAddress(self.nft_factory_contract_address), abi=self.nft_factory_abi)

            createDataNFT_events = nft_factory_contract.events.CreateDataNFT.getLogs(fromBlock=self.from_block, toBlock=to_block)
            
            # print("createDataNFT_events: ",createDataNFT_events)
            # Scan for contract with Chainlink functions events
            if createDataNFT_events:
                event_size = len(createDataNFT_events)
                print("event_size: ",event_size)
                i = 0
                blocknumInit = 0

                while i < event_size:
                    if blocknumInit != createDataNFT_events[i].blockNumber:
                        self.insert_nft_contract_deails(
                            createDataNFT_events[i].args.datasetName,
                            createDataNFT_events[i].args.dataNFTAddress,
                            createDataNFT_events[i].args.owner,
                            createDataNFT_events[i].transactionHash.hex(),
                            createDataNFT_events[i].address
                        )

                    blocknumInit = createDataNFT_events[i].blockNumber
                    i=i+1

            self.from_block = self.from_block + self.batch_size + 1
            blockDiff = target_block - self.from_block

            if(blockDiff < self.batch_size):
                self.batch_size = blockDiff

        # Update last scanned block
        try:
            Session = sessionmaker(bind=self.engine)
            self.session = Session()
            self.session.query(FactoryContractDetails).update({'last_scan_block': target_block})
            self.session.commit()
        except Exception as e:
            logging.error("Error updating the last_scan_block: ",e)
        finally:
            self.session.close()

def main():
    # Configurable parameters:
    try:
        nft_factory_contract_addr=config['NFT_CONTRACT_ADDRESS']
    except Exception as e:
        logging.error("Please check address configuration: ",e)

    # Start scanner:
    try:
        scanner_0bj = NFTScanner(nft_factory_contract_addr)
        target_block = 	scanner_0bj.w3.eth.get_block('latest')
        scanner_0bj.start_NFT_scan(target_block.number)
    except Exception as e:
        logging.error("Error while starting the scan script: ", e)

if __name__ == '__main__':
    main()
    