// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import '@openzeppelin/contracts/access/AccessControl.sol';

contract Protocol is AccessControl {
    bytes32 public constant REGULATORY_AUTHORITY_ROLE = keccak256('REGULATORY_AUTHORITY_ROLE');
    bytes32 public constant OFFSETTER_ROLE = keccak256('OFFSETTER_ROLE');

    constructor(address reguulatorAddress, address offsetrerAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REGULATORY_AUTHORITY_ROLE, reguulatorAddress);
        _grantRole(OFFSETTER_ROLE, offsetrerAddress);
    }

    function isRegulator(address addressToCheck) public view returns (bool) {
        return hasRole(REGULATORY_AUTHORITY_ROLE, addressToCheck);
    }

    function isOffsetter(address addressToCheck) public view returns (bool) {
        return hasRole(OFFSETTER_ROLE, addressToCheck);
    }
}
