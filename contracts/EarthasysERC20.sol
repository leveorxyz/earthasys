// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol';

contract EarthasysERC20 is ERC20, ERC20Burnable, Pausable, Ownable, ERC20Permit {
    string pollutantName;
    string unitName;
    string imageURI;

    constructor(
        string memory tokenName,
        string memory ticker,
        string memory _pollutantName,
        string memory _unitName,
        string memory _imageURI
    ) ERC20(tokenName, ticker) ERC20Permit('MyToken') {
        pollutantName = _pollutantName;
        unitName = _unitName;
        imageURI = _imageURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function getERC20Metadata()
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory
        )
    {
        return (name(), symbol(), pollutantName, unitName, imageURI);
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }
}
