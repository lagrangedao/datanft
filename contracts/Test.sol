// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DataNFT.sol";

/**
 * @title DataNFTFactory
 * @author 
 * @notice Creates ERC721 and ERC20 contracts
 * ERC721 contracts are DataNFTs representing one dataset
 * ERC721 Tokens can accept certain ERC20 tokens as datatokens
 */
contract Test is FunctionsClient, Ownable {
    using Functions for Functions.Request;

    uint64 private subscriptionId; // need to fund this subscription with LINK tokens
    string public source; // js code to call GET request
    address public oracleAddress;
    bytes public secret = '0x5d5cc89277ee34974edc3396aad377cf031ea822fb9979985af7cea1392141866bcc00cb151e367e2c233ab4ac3e86a7102ece28ff5c904bedf97a4ca5bd6517e907f5568374157342b85610de9779077722062f803f236fa27dcaee6863f6310fa661df258d92213eb341f892b0359ba25dfb1992bc19365be9186cb01cbdc0380de41a50dcc3e010a2a30cf3f3a67b0b1deaeaea4264f78b62f43ca9802bf0ca71781641a2659a4bb78183ae281e43f5ea89ac56aa8d4b52183487fd828bae7de4d9e14151007d838e4adeb491ac1d11a10c18d122e7b8366843856b1dd707807b6ebe0e3dda6cd9643ac4c9d5f29734c3ee80385d46c9255384ec4eb1a2b21433e79f09c6d362a08da1647da07efda5';


    struct RequestData {
        address requestor;
        string decrypted;
        bool fulfilled;
    }

    mapping(bytes32 => RequestData) public requestData;

    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    constructor(
        address oracle,
        uint64 _subscriptionId,
        string memory _source
    ) FunctionsClient(oracle) {
        subscriptionId = _subscriptionId;
        source = _source;
        oracleAddress = oracle;
    }

    /**
     * 
     * @notice sends a request to Chainlink to verify the metadata, allowing the user to claim
     */
    function requestDataNFT() public returns (bytes32) {
        string[] memory args = new string[](2);
        args[0] = addressToString(msg.sender);

        // sends the chainlink request to call API, returns reqID
        Functions.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        req.addArgs(args);
        req.addInlineSecrets(secret);
        bytes32 assignedReqID = sendRequest(req, subscriptionId, 300000);

        // stores the req info in the mapping (we need to access this info to mint later)
        RequestData storage data = requestData[assignedReqID];
        data.requestor = msg.sender;

        return assignedReqID;
    }

    /**
     * 
     * @param requestId from requestDataNFT
     * @param response successful response ecoded
     * @param err error message encoded
     * @notice the DON fulfills the request, running the source script
     * @dev response should contain the name of datasets
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {

        // update requestData information
        requestData[requestId].fulfilled = true;

        if (response.length > 0 /* check if response */) {
            requestData[requestId].decrypted = abi.decode(response, (string));
        }

        emit OCRResponse(requestId, response, err);
    }

    function addressToString(
        address _address
    ) public pure returns (string memory) {
        bytes20 _bytes = bytes20(_address);
        bytes16 _hexAlphabet = "0123456789abcdef";
        bytes memory _stringBytes = new bytes(42);
        _stringBytes[0] = "0";
        _stringBytes[1] = "x";
        for (uint i = 0; i < 20; i++) {
            uint _byte = uint8(_bytes[i]);
            _stringBytes[2 + i * 2] = _hexAlphabet[_byte >> 4];
            _stringBytes[3 + i * 2] = _hexAlphabet[_byte & 0x0f];
        }
        return string(_stringBytes);
    }

    /**
     * @notice Allows the Functions oracle address to be updated
     *
     * @param oracle New oracle address
     */
    function updateOracleAddress(address oracle) public onlyOwner {
        oracleAddress = oracle;
        setOracle(oracle);
    }

    function updateSubscriptionId(uint64 subId) public onlyOwner {
        subscriptionId = subId;
    }

    function updateSource(string memory _source) public onlyOwner {
        source = _source;
    }
}