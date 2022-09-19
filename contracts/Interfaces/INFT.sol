// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface INFT {
    struct Pollutant {
        string name;
        uint256 erc20Amount;
        uint256[] initialAmounts;
        uint256[] targetAmounts;
    }

    function mintNewProject(
        address account,
        uint256 newNFTID,
        string memory prefix,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) external;

    function mintProjects(
        uint256 prevNFTID,
        uint256 newnNFTID,
        string memory newPrefix,
        address account,
        uint256 amount,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) external;
}
