from flask import Flask, jsonify, request
from apscheduler.schedulers.background import BackgroundScheduler
from datetime import datetime
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text
from model import db
from model.nft_factory_data import NFTFactoryTransactions

import subprocess
import mysql.connector
import requests
import os
import time

import threading
from nft_scanner import main
import logging
import toml

# load environment variables from .toml file
config=toml.load('config.toml')

db_host = config['DB_HOST']
db_user = config['DB_USER']
db_password = config['DB_PASSWORD']
db_name = config['DB_NAME']

app = Flask(__name__)

# setup SQL Alchemy
app.config['SQLALCHEMY_DATABASE_URI'] = f'mysql://{db_user}:{db_password}@{db_host}/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Initialize the SQLAlchemy extension
db.init_app(app)

def execute_scanning_script():
    logging.info(f"Scanning task executed at {datetime.now()}")
    while True:
        try:
            main()
        except Exception as e:
            logging.error(e)
        
        # Delay for 3 seconds
        time.sleep(3)

t = threading.Thread(target=execute_scanning_script)
t.start()

def query_database(transaction_hash, chain_id):
    # Query database for NFT ownership record
    try:
        result = NFTFactoryTransactions.query.filter_by(transaction_hash=transaction_hash, chain_id=chain_id).first()
    except Exception as e:
        logging.error("Error fetching NFT Factory details: ",e)

    return result

@app.route('/get_factory_details', methods=['GET'])
def get_factory_details():
    # Get parameters from request query string
    transaction_hash = request.args.get('transaction_hash')
    chain_id = request.args.get('chain_id')

    result = query_database(transaction_hash,chain_id)

    # Return result as JSON
    if result:
        return {'chain_id':result.chain_id,
                'dataset_name': result.dataset_name,
                'dataNFTAddress': result.data_NFT_address,
                'owner': result.owner,
                'transaction_hash': result.transaction_hash,
                'contract_address': result.contract_address
                }
    else:
        return 'NFT Factory record not found'
   

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)