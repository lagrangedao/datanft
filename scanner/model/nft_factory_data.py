from sqlalchemy import Column, Integer, String
from model import db

class NFTFactoryTransactions(db.Model):
    __tablename__ = 'nft_factory_transactions'

    id = Column(Integer, primary_key=True)
    dataset_name = Column(String)
    data_NFT_address = Column(String)
    owner = Column(String)
    transaction_hash = Column(String)
    contract_address = Column(String)

class FactoryContractDetails(db.Model):
    __tablename__ = 'factory_contract_details'
    id = Column(Integer, primary_key=True)
    last_scan_block = Column(Integer)
    factory_contract_address = Column(String)
    owner = Column(String)