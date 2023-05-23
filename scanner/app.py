from flask import Flask, request
from scanner.model.nft_factory_data import get_nft_factory_transactions
from scanner import getConfig
from scanner.model import getDb
from apscheduler.schedulers.background import BackgroundScheduler
from scanner.nft_scanner import scan_chain
from datetime import datetime

config = getConfig()
session = getDb()
app = Flask(__name__)


def initialize_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(func=scan_chain, trigger='date', next_run_time=datetime.now())
    scheduler.add_job(func=scan_chain, trigger='interval', seconds=30)
    scheduler.start()


@app.route('/get_factory_details', methods=['GET'])
def get_factory_details():
    transaction_hash = request.args.get('transaction_hash')
    chain_id = request.args.get('chain_id')
    print(transaction_hash, chain_id)
    result = get_nft_factory_transactions(session, chain_id, transaction_hash)
    if result:
        return {'chain_id': result.chain_id,
                'dataset_name': result.dataset_name,
                'dataNFTAddress': result.data_NFT_address,
                'owner': result.owner,
                'transaction_hash': result.transaction_hash,
                'contract_address': result.contract_address
                }
    else:
        return 'NFT Factory record not found'


if __name__ == '__main__':
    initialize_scheduler()
    app.run(host=config['SERVER_HOST'], port=config['SERVER_PORT'])
