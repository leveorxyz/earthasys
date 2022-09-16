// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import '@openzeppelin/contracts/access/AccessControl.sol';

contract Protocol is AccessControl {
    bytes32 public constant REGULATORY_AUTHORITY_ROLE = keccak256('REGULATORY_AUTHORITY_ROLE');
    bytes32 public constant OFFSETTER_ROLE = keccak256('OFFSETTER_ROLE');

    constructor(address reguulatorAddress, address offsetrerAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, reguulatorAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, offsetrerAddress);
    }
}
