// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

//import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./DataNFT.sol";

/**
 * @title DataNFTFactory
 * @author 
 * @notice Creates ERC721 and ERC20 contracts
 * ERC721 contracts are DataNFTs representing one dataset
 * ERC721 Tokens can accept certain ERC20 tokens as datatokens
 */
contract DataNFTFactory {

    address private implementation;
    mapping(address => mapping(string => address)) public dataNFTAddresses;

    event CreateDataNFT(address indexed owner, string datasetName, address dataNFTAddress);

    constructor() {
        implementation = address(new DataNFT());
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
}