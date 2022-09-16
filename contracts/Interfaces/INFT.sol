// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface INFT {
    struct Pollutant {
        string name;
        uint256[] intialAmounts;
        uint256[] targetAmounts;
    }

    function mintNewProject(
        address account,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) external;

    function mintProjects(
        uint256 nftID,
        address account,
        uint256 amount,
        bytes memory data,
        Pollutant[] memory pollutantDetails
    ) external;
}
