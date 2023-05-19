import time

from web3 import Web3
from web3.middleware import geth_poa_middleware
from model.nft_factory_data import update_last_scan_block, find_all_chain_list, \
    insert_dataset_nft_transaction
import json
import logging
from scanner.model import getDb

# set up logging to file
logging.basicConfig(level=logging.INFO,
                    format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                    datefmt='%m-%d %H:%M')
# define a Handler which writes INFO messages or higher to the sys.stderr
console = logging.StreamHandler()
console.setLevel(logging.INFO)

session = getDb()


class NFTFactoryScanner:
    def __init__(self, chain_info):
        self.nft_factory_contract_address = chain_info.factory_contract_address
        self.nft_factory_abi_file_path = '../contracts/abi/DataNFTFactory.json'
        self.session = session
        self.w3 = Web3(Web3.HTTPProvider(chain_info.rpc_url))
        self.w3.middleware_onion.inject(geth_poa_middleware, layer=0)
        self.nft_factory_abi = json.load(open(self.nft_factory_abi_file_path))
        self.lastScannedBlock = chain_info.last_scan_block
        self.batch_size = 100
        self.chain_ID = chain_info.chain_id
        self.from_block = self.lastScannedBlock

    def start_NFT_scan(self, target_block):
        logging.info("Scanning for NFT Factory contract events")
        while self.from_block < target_block:
            to_block = self.from_block + self.batch_size
            logging.info(f"scanning from {self.from_block} to {to_block}")
            nft_factory_contract = self.w3.eth.contract(
                address=Web3.to_checksum_address(self.nft_factory_contract_address), abi=self.nft_factory_abi)

            create_data_nft_events = nft_factory_contract.events.CreateDataNFT.get_logs(fromBlock=self.from_block,
                                                                                        toBlock=to_block)

            if create_data_nft_events:
                for even in create_data_nft_events:
                    print(even)
                    insert_dataset_nft_transaction(session,
                                                   self.chain_ID,
                                                   even.args.datasetName,
                                                   even.args.dataNFTAddress,
                                                   even.args.owner,
                                                   even.transactionHash.hex(),
                                                   even.address
                                                   )
            self.from_block = self.from_block + self.batch_size + 1
            block_diff = target_block - self.from_block
            if block_diff < self.batch_size:
                self.batch_size = block_diff
            update_last_scan_block(session, self.chain_ID, to_block)
            time.sleep(1)


def scan_chain():
    all_chain = find_all_chain_list(session)
    for chain_info in all_chain:
        scanner_obj = NFTFactoryScanner(chain_info)
        target_block = scanner_obj.w3.eth.get_block('latest')
        scanner_obj.start_NFT_scan(target_block.number)


if __name__ == '__main__':
    scan_chain()
