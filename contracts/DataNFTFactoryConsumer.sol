// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DataNFT.sol";

contract DataNFTFactoryConsumer is
    ChainlinkClient,
    Ownable
{
    using Chainlink for Chainlink.Request;

    bytes32 public jobId;
    uint256 public fee;

    string public baseUrl = "https://api.lagrangedao.org/spaces/";

    address private implementation;

    struct RequestData {
        address requestor;
        string datasetName;
        string uri;
        bool fulfilled;
        bool claimable;
    }

    struct RequestArguements {
        address requestor;
        string datasetName;
    }

    mapping(bytes32 => RequestArguements) public idToArgs;
    mapping(address => mapping(string => RequestData)) public requestData;
    mapping(address => mapping(string => address)) public dataNFTAddresses;

    event OracleResult(bytes32 indexed requestId, string uri);
    event CreateDataNFT(address indexed owner, string datasetName, address dataNFTAddress);
    
    constructor() {
        setChainlinkToken(0xb0897686c545045aFc77CF20eC7A532E3120E0F1);
        setChainlinkOracle(0x9F306bB9da1a12bF1590d3EA65e038fC414d6b68);
        jobId = 'fb6846302d324792955cb3623f636088';
        fee = 0.1 ether; // 0,1 * 10**18 (Varies by network and job)

        implementation = address(new DataNFT());
    }

    function requestDataNFT(string memory datasetName) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // BUILD URL
        string memory urlWithAddress = concat(concat(baseUrl, addressToString(msg.sender)), "/");
        string memory urlWithDataset = concat(concat(urlWithAddress, datasetName), "/generate_metadata");

        req.add("url", urlWithDataset);
        req.add("path", "data,metadata_cid");

        bytes32 assignedReqID = sendChainlinkRequest(req, fee);
        idToArgs[assignedReqID] = RequestArguements(msg.sender, datasetName);
        RequestData storage data = requestData[msg.sender][datasetName];
        data.requestor = msg.sender;
        data.datasetName = datasetName;
        data.fulfilled = false;
        data.claimable = false;

        return assignedReqID;
    }

    function fulfill(
        bytes32 requestId,
        bytes memory uriBytes
    ) public recordChainlinkFulfillment(requestId) {
        RequestArguements memory args = idToArgs[requestId];
        RequestData storage data = requestData[args.requestor][args.datasetName];

        data.fulfilled = true;

        if (uriBytes.length > 0) {
            data.uri = string(uriBytes);
            data.claimable = true;
        }

        emit OracleResult(requestId, string(uriBytes));
    }

    function claimDataNFT(string memory datasetName) public {
        RequestData storage data = requestData[msg.sender][datasetName];
        require(data.claimable, "this dataNFT is not claimable yet");
        address clone = Clones.clone(implementation);
        DataNFT(clone).initialize(data.requestor, data.datasetName, data.uri);

        dataNFTAddresses[data.requestor][data.datasetName] = clone;
        emit CreateDataNFT(data.requestor, data.datasetName, clone);
    }

    function concat(string memory a, string memory b) public pure returns (string memory) {
        return string(abi.encodePacked(a, b));
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

    function setOracleAddress(address oracle) public onlyOwner {
        setChainlinkOracle(oracle);
    }

    function getOracle() public view returns (address) {
        return chainlinkOracleAddress();
    }

    function setLinkToken(address token) public onlyOwner {
        setChainlinkToken(token);
    }


    function setJobId(bytes32 job) public onlyOwner {
        jobId = job;
    }

    function setFee(uint _fee) public onlyOwner {
        fee = _fee;
    }

    function setBaseUrl(string memory url) public onlyOwner {
        baseUrl = url;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

    function withdraw(address tokenAddress) public onlyOwner {
        LinkTokenInterface token = LinkTokenInterface(tokenAddress);
        require(
            token.transfer(msg.sender, token.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
} 