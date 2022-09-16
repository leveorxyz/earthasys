// SPDX-License-Identifier: MIT

pragma solidity ^0.8.15;

interface IProtocol {
    function isRegulator(address addressToCheck) external view returns (bool);

    function isOffsetter(address addressToCheck) external view returns (bool);
}
