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

    bytes32 private jobId;
    uint256 private fee;
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

    event OracleResult(bytes32 indexed requestId, string uri);
    event CreateDataNFT(address indexed owner, string datasetName, address dataNFTAddress);
    event RequestDataSent (string request);

    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x12A3d7759F745f4cb8EE8a647038c040cB8862A5);
        oracleAddress = 0x12A3d7759F745f4cb8EE8a647038c040cB8862A5;
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

        string memory urlWithAddress = concat(concat(baseUrl, addressToString(msg.sender)), "/");
        string memory urlWithDataset = concat(concat(urlWithAddress, datasetName), "/'");
        string memory requestUrl = concat(urlWithDataset, "generate_metadata");
        string memory x = concat('{\"url\":\"', requestUrl);
        string memory y = concat(x, '\", \"headers\": [{ \"name\": \"Authorization\", \"value\": \"Bearer ');
        string memory z = concat(concat(y, secret), '\"} ]}');

        req.add("requestData", z);


        bytes32 assignedReqID = sendChainlinkRequest(req, fee);
        idToArgs[assignedReqID] = RequestArguements(msg.sender, datasetName);
        RequestData storage data = requestData[msg.sender][datasetName];
        data.requestor = msg.sender;
        data.datasetName = datasetName;

        emit RequestDataSent(z);

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

    function updateOracleAddress(address oracle) public onlyOwner {
        oracleAddress = oracle;
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

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }

} 