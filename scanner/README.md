## Steps to run the nft scanner and the flask service:
1. Rename the `config.toml.example` file and configure it accoding to your parameters.
2. Create the `nft_factory_data` database as well as the `factory_contract_details` and `nft_factory_transactions` tables by executing the SQL scripts found in `scanner/db/SQL_COMMANDS.sql` file.
3. Insert the NFT factory contract details in the `factory_contract_details` table by executing the following:
    ```
    INSERT into factory_contract_details(chain_id,last_scan_block,factory_contract_address,owner) VALUES (3141,353737,'0x93C2aB6d92b3d40DEcf3eaFEA2B8b539EE78738e','0xA878795d2C93985444f1e2A077FA324d59C759b0');
    ```
4. Run the `nft_scanner.py` script by executing the following:
    ```
    python3 nft_scanner.py
    ```
Alternatively,
    Run the flask service by executing the following command:
    ```
    python3 app.py
    ```
    
### To query the database:
1. Make sure the flask service is running.
2. Use a tool like Postman or CURL to send a GET request to the `/get_factory_details` endpoint with the following parameters:
    ```
    transaction_hash
    chain_id
    ```

Example request with parameter:
```
http://127.0.0.1:5000/get_factory_details?transaction_hash=0xa74308419dfe043a84e2c515f9d56532df39619705174a3774352413e4bb54f8&chain_id=3141
```
