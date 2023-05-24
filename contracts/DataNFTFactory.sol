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
contract DataNFTFactory is FunctionsClient, Ownable {
    using Functions for Functions.Request;

    uint64 private subscriptionId; // need to fund this subscription with LINK tokens
    string public source; // js code to call GET request
    address public oracleAddress;

    address private implementation;

    struct RequestData {
        address requestor;
        string uri;
        bool fulfilled;
        bool claimable;
    }

    mapping(bytes32 => RequestData) public requestData;
    mapping(address => mapping(string => address)) public dataNFTAddresses;

    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);
    event CreateDataNFT(address indexed owner, string datasetName, address dataNFTAddress);

    constructor(
        address oracle,
        uint64 _subscriptionId,
        string memory _source
    ) FunctionsClient(oracle) {
        subscriptionId = _subscriptionId;
        source = _source;
        oracleAddress = oracle;

        implementation = address(new DataNFT());
    }

    /**
     * 
     * @param metadataUri IPFS URL for the dataset info. should be JSON containing:
     * - name
     * - symbol
     * - datasetUrl
     * - license
     * @notice sends a request to Chainlink to verify the metadata, allowing the user to claim
     */
    function requestDataNFT(string memory metadataUri) public returns (bytes32) {
        string[] memory args = new string[](2);
        args[0] = addressToString(msg.sender);
        args[1] = metadataUri;

        // sends the chainlink request to call API, returns reqID
        Functions.Request memory req;
        req.initializeRequestForInlineJavaScript(source);
        req.addArgs(args);
        bytes32 assignedReqID = sendRequest(req, subscriptionId, 300000);

        // stores the req info in the mapping (we need to access this info to mint later)
        RequestData storage data = requestData[assignedReqID];
        data.requestor = msg.sender;
        data.uri = metadataUri;

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
        if (true /* check if response */) {
            requestData[requestId].claimable = true;
        }

         // update requestData information
        requestData[requestId].fulfilled = true;

        emit OCRResponse(requestId, response, err);
    }

    /**
     * @dev TODO, not sure if I should use requestID or metadataURL
     */
    function claimDataNFT(
        string memory datasetName,
        string memory uri
    ) public {
        address clone = Clones.clone(implementation);
        DataNFT(clone).initialize(msg.sender, datasetName, uri);

        dataNFTAddresses[msg.sender][datasetName] = clone;

        emit CreateDataNFT(msg.sender, datasetName, clone);
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
}