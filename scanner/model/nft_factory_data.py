from sqlalchemy import Column, Integer, String
from scanner.model import Base


class NFTFactoryTransactions(Base):
    __tablename__ = 'nft_factory_transactions'
    __table_args__ = {'extend_existing': True}
    id = Column(Integer, primary_key=True)
    chain_id = Column(String)
    dataset_name = Column(String)
    data_NFT_address = Column(String)
    owner = Column(String)
    transaction_hash = Column(String)
    contract_address = Column(String)


class FactoryContractDetails(Base):
    __tablename__ = 'factory_contract_details'
    __table_args__ = {'extend_existing': True}
    id = Column(Integer, primary_key=True)
    chain_id = Column(String)
    last_scan_block = Column(Integer)
    factory_contract_address = Column(String)
    owner = Column(String)
    rpc_url = Column(String)


def find_all_chain_list(session):
    try:
        chain_list = session.query(FactoryContractDetails).all()
        return chain_list
    except Exception as e:
        print("Error fetching the chain list: ", e)
    finally:
        session.close()


def insert_dataset_nft_transaction(session, chain_id, dataset_name, data_NFT_address, owner, transaction_hash,
                                   contract_address):
    try:
        # Check if a transaction with the same chain_id and transaction_hash exists in the database
        existing_transaction = session.query(NFTFactoryTransactions).filter_by(chain_id=chain_id,
                                                                               transaction_hash=transaction_hash).first()
        # If no existing transaction is found, insert the new transaction
        if not existing_transaction:
            session.add(NFTFactoryTransactions(chain_id=chain_id, dataset_name=dataset_name,
                                               data_NFT_address=data_NFT_address, owner=owner,
                                               transaction_hash=transaction_hash, contract_address=contract_address))
            session.commit()
        else:
            print("Transaction already exists with the same chain_id and transaction_hash.")
    except Exception as e:
        print("Error inserting the dataset NFT transaction: ", e)
    finally:
        session.close()


# Update last scanned block
def update_last_scan_block(session, chain_id, last_scan_block):
    try:
        session.query(FactoryContractDetails).filter_by(chain_id=chain_id).update({'last_scan_block': last_scan_block})
        session.commit()
    except Exception as e:
        print("Error updating the last_scan_block: ", e)
    finally:
        session.close()


## get nft_factory_transactions by chain_id and transaction_hash
def get_nft_factory_transactions(session, chain_id, transaction_hash):
    try:
        nft_factory_transactions = session.query(NFTFactoryTransactions).filter_by(chain_id=chain_id,
                                                                                   transaction_hash=transaction_hash).first()
        return nft_factory_transactions
    except Exception as e:
        print("Error fetching the nft_factory_transactions: ", e)
    finally:
        session.close()