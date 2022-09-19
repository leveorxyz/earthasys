// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "./EarthasysERC20.sol";
import "./Interfaces/INFT.sol";

contract EarthasysNFT is ERC1155, AccessControl, Pausable, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    uint256[] private allIDs;
    mapping(uint256=>uint256) idIndex;
    mapping(uint256=>string) tokenIDPrefix;

    mapping(string => address) _pollutantERC20Addresses;

    // struct Pollutant {
    //     string name;
    //     uint256 erc20Amount;
    //     uint256[] initialAmounts;
    //     uint256[] targetAmounts;
    // }

    mapping(uint256 => INFT.Pollutant[]) _onChainMetadata;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor(address _protocolAddress) ERC1155("ipfs://f0{id}") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _protocolAddress);
    }

    function addNewERC20(
        string memory newPollutentName,
        string memory tokenName,
        string memory ticker,
        string memory unitName,
        string memory imageURI,
        uint256 price
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            _pollutantERC20Addresses[newPollutentName] == address(0),
            "Already added"
        );
        EarthasysERC20 newERC20 = new EarthasysERC20(
            tokenName,
            ticker,
            newPollutentName,
            unitName,
            imageURI,
            price
        );
        _pollutantERC20Addresses[newPollutentName] = address(newERC20);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function getERC20Address(string memory pollutentName)
        public
        view
        returns (address)
    {
        return _pollutantERC20Addresses[pollutentName];
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function uint2hexstr(uint256 i) public pure returns (string memory) {
        if (i == 0) return "0";
        uint256 j = i;
        uint256 length;
        while (j != 0) {
            length++;
            j = j >> 4;
        }
        uint256 mask = 15;
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        while (i != 0) {
            uint256 curr = (i & mask);
            bstr[--k] = curr > 9
                ? bytes1(uint8(55 + curr))
                : bytes1(uint8(48 + curr)); // 55 = 65 - 10
            i = i >> 4;
        }
        return string(bstr);
    }

    function uri(uint256 _tokenID)
        public
        view
        override
        returns (string memory)
    {
        string memory hexstringtokenID;
        hexstringtokenID = uint2hexstr(_tokenID);

        return string(abi.encodePacked("ipfs://f0", tokenIDPrefix[_tokenID], hexstringtokenID));
    }

    // TODO: Add support to mint multiple new projects
    function mintNewProject(
        address account,
        uint256 newNFTID,
        string memory prefix,
        bytes memory data,
        INFT.Pollutant[] memory pollutantDetails
    ) public onlyRole(MINTER_ROLE) {
        require(!exists(newNFTID), "NFT ID already exist");

        uint256 totalPolutants = pollutantDetails.length;
        for (uint256 i = 0; i < totalPolutants; i++) {
            require(
                pollutantDetails[i].initialAmounts.length == 1 &&
                    pollutantDetails[i].targetAmounts.length == 1 &&
                    _pollutantERC20Addresses[pollutantDetails[i].name] !=
                    address(0),
                "Invalid arguments"
            );
        }
        INFT.Pollutant[] storage newPollutantDetails = _onChainMetadata[newNFTID];
        for (uint256 index = 0; index < totalPolutants; index++) {
            newPollutantDetails.push(pollutantDetails[index]);
        }
        _mint(account, newNFTID, 1, data);
        idIndex[newNFTID] = allIDs.length; 
        allIDs.push(newNFTID);
        tokenIDPrefix[newNFTID] = prefix;
    }

    function updatePrefixIndex(uint256 prevNFTID, uint256 newNFTID, string memory newPrefix) internal {
        uint256 prevIndex = idIndex[prevNFTID];
        allIDs[prevIndex] = newNFTID;
        idIndex[newNFTID] = prevIndex;
        idIndex[prevNFTID] = 0;
        tokenIDPrefix[prevNFTID] = "";
        tokenIDPrefix[newNFTID] = newPrefix;
    }

  
    // expect to get intialAmount and targetAmount array with the previous intitalAmount and targetAmount
    // however, erc20 amount is expected to reflect of the new projects
    function mintProjects(
        uint256 prevNFTID,
        uint256 newNFTID,
        string memory newPrefix,
        address account,
        uint256 amount,
        bytes memory data,
        INFT.Pollutant[] memory pollutantDetails
    ) public onlyRole(MINTER_ROLE) {
        require(exists(prevNFTID), "Project not minted");
        require(!exists(newNFTID), "Project already minted");
        uint256 prevBalance = this.balanceOf(account, prevNFTID);
        require(prevBalance > 0, "Not the owner");
        uint256 totalPolutants = pollutantDetails.length;
        for (uint256 i = 0; i < totalPolutants; i++) {
            INFT.Pollutant memory pollutant = pollutantDetails[i];
            require(
                pollutant.initialAmounts.length ==
                    amount + _onChainMetadata[prevNFTID][i].initialAmounts.length &&
                    pollutant.targetAmounts.length ==
                    amount + _onChainMetadata[prevNFTID][i].targetAmounts.length &&
                    _pollutantERC20Addresses[pollutant.name] != address(0),
                "Invalid arguments"
            );
            EarthasysERC20(_pollutantERC20Addresses[pollutant.name]).mint(
                pollutant.erc20Amount
            );
        }
        uint256 totalPollutants = pollutantDetails.length;
        INFT.Pollutant[] memory prevPollutantDetails = _onChainMetadata[prevNFTID];
        INFT.Pollutant[] storage newPollutantDetails = _onChainMetadata[newNFTID];
        for (uint256 index = 0; index < totalPollutants; index++) {
            newPollutantDetails[index].initialAmounts = pollutantDetails[index]
                .initialAmounts;
            newPollutantDetails[index].targetAmounts = pollutantDetails[index]
                .targetAmounts;
            newPollutantDetails[index].erc20Amount = prevPollutantDetails[index].erc20Amount + pollutantDetails[index]
                .erc20Amount;
        }
        
        _burn(account, prevNFTID, prevBalance);
        // _onChainMetadata[lastId] = pollutantDetails;
        updatePrefixIndex(prevNFTID, newNFTID, newPrefix);
        _mint(account, newNFTID, prevBalance+amount, data);
    }

    function getAllTokenIds() public view returns(uint256[] memory) {
        return allIDs;
    }

    function getOnChainMetadata(uint256 nftID)
        public
        view
        returns (INFT.Pollutant[] memory)
    {
        return _onChainMetadata[nftID];
    }

    // TODO: add mintbatch (might have to skip cause could be too complex)
    // function mintBatch(
    //     address to,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) public onlyRole(MINTER_ROLE) {
    //     uint256 totalNewIds = amounts.length; //2
    //     uint256 lastNewID = totalNewIds + lastId; //2
    //     uint256[] memory ids = new uint256[](totalNewIds);
    //     for (uint256 i = lastId; i < lastNewID; i++) {
    //         ids[i - lastId] = i;
    //     }
    //     _mintBatch(to, ids, amounts, data);
    // }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
