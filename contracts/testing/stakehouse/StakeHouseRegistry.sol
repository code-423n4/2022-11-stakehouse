pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

contract StakeHouseRegistry {

    function transferOwnership(address) external {
        // No mock implementation at the moment
    }

    function setGateKeeper(address) external {
        // No mock implementation at the moment
    }

    function isMemberPermitted(bytes calldata) external pure returns (bool) {
        return true;
    }

    function addMember(address , bytes calldata ) external {
        // No mock implementation at the moment
    }

    function kick(bytes calldata ) external {
        // No mock implementation at the moment
    }

    function rageQuit(bytes calldata ) external {
        // No mock implementation at the moment
    }

    function numberOfMemberKNOTs() external pure returns (uint256) {
        return 0;
    }

    function numberOfActiveKNOTsThatHaveNotRageQuit() external pure returns (uint256) {
       return 0;
    }

    function isActiveMember(bytes calldata) external pure returns (bool) {
        return true;
    }

    function hasMemberRageQuit(bytes calldata) public pure returns (bool) {
        return false;
    }

    function getMemberInfoAtIndex(uint256) public pure returns (
        address applicant,
        uint256 knotMemberIndex,
        uint16 flags,
        bool isActive
    ) {
        applicant = address(0);
        knotMemberIndex = 0;
        flags = 1;
        isActive = true;
    }

    function getMemberInfo(bytes memory) public pure returns (
        address applicant,      // Address of ETH account that added the member to the StakeHouse
        uint256 knotMemberIndex,// KNOT Index of the member within the StakeHouse
        uint16 flags,          // Flags associated with the member
        bool isActive           // Whether the member is active or knot
    ) {
        applicant = address(0);
        knotMemberIndex = 0;
        flags = 1;
        isActive = true;
    }

    /// @dev given member flag values, determines if a member is active or not
    function _isActiveMember(bytes memory , uint16 ) internal pure returns (bool) {
        return true;
    }
}
