// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

import './EarthasysERC20.sol';

contract EarthasysNFT is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant URI_SETTER_ROLE = keccak256('URI_SETTER_ROLE');
    bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
    bytes32 public constant MINTER_ROLE = keccak256('MINTER_ROLE');
    bytes32 public constant UPGRADER_ROLE = keccak256('UPGRADER_ROLE');

    uint256 private lastId;

    mapping(string => address) _pollutantERC20Addresses;

    struct Pollutant {
        string name;
        uint256 erc20Amount;
        uint256[] intialAmounts;
        uint256[] targetAmounts;
    }

    mapping(uint256 => Pollutant[]) _onChainMetadata;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _protocolAddress) public initializer {
        __ERC1155_init('https://bafybeicw3mj2lc3k6fc2zs5g4zravbh2ekddkhadbjj7elngtqebkh6xyu.ipfs.nftstorage.link/');
        __AccessControl_init();
        __Pausable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, _protocolAddress);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

    function addNewERC20(
        string memory newPollutentName,
        string memory tokenName,
        string memory ticker,
        string memory unitName,
        string memory imageURI,
        uint256 price
    ) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(_pollutantERC20Addresses[newPollutentName] == address(0), 'Already added');
        EarthasysERC20 newERC20 = new EarthasysERC20(tokenName, ticker, newPollutentName, unitName, imageURI, price);
        _pollutantERC20Addresses[newPollutentName] = address(newERC20);
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mintNewProject(
        address account,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) public onlyRole(MINTER_ROLE) {
        uint256 totalPolutants = pollutantDetails.length;
        for (uint256 i = 0; i < totalPolutants; i++) {
            require(
                pollutantDetails[i].intialAmounts.length == 1 &&
                    pollutantDetails[i].targetAmounts.length == 1 &&
                    _pollutantERC20Addresses[pollutantDetails[i].name] != address(0),
                'Invalid arguments'
            );
        }
        uint256 totalPollutants = pollutantDetails.length;
        Pollutant[] storage newPollutantDetails = _onChainMetadata[lastId];
        for (uint256 index = 0; index < totalPollutants; index++) {
            newPollutantDetails[index] = pollutantDetails[index];
        }
        _mint(account, lastId, 1, data);
        lastId++;
    }

    // expect to get intialAmount and targetAmount array with the previous intitalAmount and targetAmount
    // howeven, erc20 amount is expected to reflect of the new projects
    function mintProjects(
        uint256 nftID,
        address account,
        uint256 amount,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) public onlyRole(MINTER_ROLE) {
        uint256 totalPolutants = pollutantDetails.length;
        require(exists(nftID), 'Project not minted');
        for (uint256 i = 0; i < totalPolutants; i++) {
            Pollutant memory pollutant = pollutantDetails[i];
            require(
                pollutant.intialAmounts.length == amount + _onChainMetadata[nftID][i].intialAmounts.length &&
                    pollutant.targetAmounts.length == amount + _onChainMetadata[nftID][i].targetAmounts.length &&
                    _pollutantERC20Addresses[pollutant.name] != address(0),
                'Invalid arguments'
            );
            EarthasysERC20(_pollutantERC20Addresses[pollutant.name]).mint(pollutant.erc20Amount);
        }
        uint256 totalPollutants = pollutantDetails.length;
        Pollutant[] storage newPollutantDetails = _onChainMetadata[lastId];
        for (uint256 index = 0; index < totalPollutants; index++) {
            newPollutantDetails[index].intialAmounts = pollutantDetails[index].intialAmounts;
            newPollutantDetails[index].targetAmounts = pollutantDetails[index].targetAmounts;
            newPollutantDetails[index].erc20Amount += pollutantDetails[index].erc20Amount;
        }
        // _onChainMetadata[lastId] = pollutantDetails;
        _mint(account, nftID, amount, data);
    }

    function getOnChainMetadata(uint256 nftID) public view returns (Pollutant[] memory) {
        return _onChainMetadata[nftID];
    }

    // TODO: add on chain metadata
    function mintBatch(
        address to,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyRole(MINTER_ROLE) {
        uint256 totalNewIds = amounts.length; //2
        uint256 lastNewID = totalNewIds + lastId; //2
        uint256[] memory ids = new uint256[](totalNewIds);
        for (uint256 i = lastId; i < lastNewID; i++) {
            ids[i - lastId] = i;
        }
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155Upgradeable, ERC1155SupplyUpgradeable) whenNotPaused {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
