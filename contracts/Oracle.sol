// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import '@openzeppelin/contracts/access/Ownable.sol';

contract Oracle is Ownable {
    // nftID => project instance => pollutant => current level
    mapping(uint256 => mapping(uint256 => mapping(string => uint256))) currentPollutionLevel;

    constructor() {}

    function addCurrentPollutantLevel(
        uint256 nftID,
        uint256 projectId,
        string memory pollutant,
        uint256 currentLevel
    ) public onlyOwner {
        currentPollutionLevel[nftID][projectId][pollutant] = currentLevel;
    }
}
