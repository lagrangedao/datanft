// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./DataToken.sol";

contract DataNFT is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIdCounter;

    string public contractURI; // dataset metadata
    address public factory;

    mapping(uint => address) public idToDataToken;
    event DeployDataToken(uint tokenId, address dataTokenAddress);

    // owner and factory are admins
    modifier onlyAdmin {
        require(msg.sender == owner() || msg.sender == factory);
        _;
   }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        // _disableInitializers();
    }

    // factory should initialize contract
    function initialize(address owner, string memory name) initializer public {
        __ERC721_init(name, "DATA");
        __Ownable_init();

        factory = msg.sender;
        transferOwnership(owner);
    }

    /**
     * @notice creates a new version for the dataset, sub-licensed to recipient
     * @param recipient - sub-licensee
     */
    function mint(address recipient) public onlyAdmin {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();

        _safeMint(recipient, tokenId);
    }

    /**
     * @notice deploys a new data token for this dataset.
     * @dev each token gets 1 datatoken
     */
    function deployDataToken(uint tokenId, string memory name, string memory symbol) public {
        require(ownerOf(tokenId) == msg.sender);
        DataToken dataToken = new DataToken(name, symbol);
        idToDataToken[tokenId] = address(dataToken);
        emit DeployDataToken(tokenId, address(dataToken));
    }

    function setContractUri(string memory uri) public onlyAdmin {
        contractURI = uri;
    }

    function totalSupply() public view returns (uint) {
        return _tokenIdCounter.current();
    }
}