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
    address public oracleAddress;

    string public baseUrl = "https://api.lagrangedao.org/datasets/";

    address private implementation;
    string private secret;

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

    event OracleResult(bytes32 indexed requestId, string datasetName);
    event CreateDataNFT(address indexed owner, string datasetName, address dataNFTAddress);

    constructor(
    ) {
        setChainlinkToken(0x779877A7B0D9E8603169DdbD7836e478b4624789);
        setChainlinkOracle(0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD);
        oracleAddress = 0x6090149792dAAeE9D1D568c9f9a6F6B46AA29eFD;
        jobId = "7d80a6386ef543a3abb52817f6707e3b";
        fee = 0.10 ether; 

        implementation = address(new DataNFT());
    }

    function requestDataNFT(string memory datasetName, string memory ipfs_url) public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req.add("get", ipfs_url);
        req.add("path", "name");
        // req.add("Bearer");


        bytes32 assignedReqID = sendChainlinkRequest(req, fee);
        idToArgs[assignedReqID] = RequestArguements(msg.sender, datasetName);
        RequestData storage data = requestData[msg.sender][datasetName];
        data.requestor = msg.sender;
        data.datasetName = datasetName;
        data.uri = ipfs_url;
        data.fulfilled = false;
        data.claimable = false;

        return assignedReqID;
    }

    function fulfill(
        bytes32 requestId,
        string memory nameFromMetadata
    ) public recordChainlinkFulfillment(requestId) {
        RequestArguements memory args = idToArgs[requestId];
        RequestData storage data = requestData[args.requestor][args.datasetName];

        data.fulfilled = true;

        if (keccak256(bytes(data.datasetName)) == keccak256(bytes(nameFromMetadata))) {
            data.claimable = true;
        }

        emit OracleResult(requestId, string(nameFromMetadata));
    }

    function claimDataNFT(string memory datasetName) public {
        RequestData storage data = requestData[msg.sender][datasetName];
        require(data.claimable, "this dataNFT is not claimable yet");
        address clone = Clones.clone(implementation);
        DataNFT(clone).initialize(data.requestor, data.datasetName, data.uri);

        dataNFTAddresses[data.requestor][data.datasetName] = clone;
        emit CreateDataNFT(data.requestor, data.datasetName, clone);
    }

    function updateOracleAddress(address oracle) public onlyOwner {
        oracleAddress = oracle;
        setChainlinkOracle(oracle);
    }

    function updateJobId(bytes32 job) public onlyOwner {
        jobId = job;
    }

    function updateFee(uint _fee) public onlyOwner {
        fee = _fee;
    }

    function updateSecret(string memory newSecret) public onlyOwner {
        secret = newSecret;
    }

    function updateChainlinkToken(address token) public onlyOwner {
        setChainlinkToken(token);
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