// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
import '@openzeppelin/contracts/access/AccessControl.sol';
import './Interfaces/INFT.sol';

contract Protocol is AccessControl {
    bytes32 public constant REGULATORY_AUTHORITY_ROLE = keccak256('REGULATORY_AUTHORITY_ROLE');
    bytes32 public constant OFFSETTER_ROLE = keccak256('OFFSETTER_ROLE');

    bool intializeCalled;
    INFT nftContract;

    constructor(address reguulatorAddress, address offsetrerAddress) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(REGULATORY_AUTHORITY_ROLE, reguulatorAddress);
        _grantRole(OFFSETTER_ROLE, offsetrerAddress);
    }

    function initialize(address _nftAddress) public {
        require(!intializeCalled, 'Already intialize');
        nftContract = INFT(_nftAddress);
        intializeCalled = true;
    }

    function VerifySignature(
        bytes32 _hashedMessage,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public pure returns (address) {
        bytes memory prefix = '\x19Ethereum Signed Message:\n32';
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _hashedMessage));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    function isRegulator(address addressToCheck) public view returns (bool) {
        return hasRole(REGULATORY_AUTHORITY_ROLE, addressToCheck);
    }

    function isOffsetter(address addressToCheck) public view returns (bool) {
        return hasRole(OFFSETTER_ROLE, addressToCheck);
    }

    function addNewProject(
        address account,
        uint256 nftID,
        bytes memory data,
        INFT.Pollutant[] memory pollutantDetails
    ) public {
        require(isRegulator(msg.sender), 'Not a regulator');
        nftContract.mintNewProject(account, nftID, data, pollutantDetails);
    }

    function instantiateNewProjects(
        uint256 prevNFTID,
        uint256 newNFTID,
        address account,
        uint256 amount,
        bytes memory data,
        INFT.Pollutant[] memory pollutantDetails,
        bytes32[] memory _hashedMessages,
        uint8[] memory _Vs,
        bytes32[] memory _Rs,
        bytes32[] memory _Ss
    ) public // bytes32 _hashedMessage2,
    // uint8 _v2,
    // bytes32 _r2,
    // bytes32 _s2
    {
        address signer1 = VerifySignature(_hashedMessages[0], _Vs[0], _Rs[0], _Ss[0]);
        address signer2 = VerifySignature(_hashedMessages[0], _Vs[0], _Rs[0], _Ss[0]);
        require(isRegulator(signer1), 'Not a regulator');
        require(isOffsetter(signer2), 'Not a offsetter');
        nftContract.mintProjects(prevNFTID, newNFTID, account, amount, data, pollutantDetails);
    }
}
