// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.17;

interface IGroupStorage {
    function set(uint256) external;
    function remove(uint256) external returns (address);
}

contract GroupStorage {
    mapping(uint256 => address) public members;

    function set(uint256 pubkey) external {
        // Make sure pubkey is not registered already
        require(members[pubkey] == address(0), "Pubkey already registered");

        members[pubkey] = tx.origin;
    }

    function remove(uint256 pubkey) external returns (address) {
        address memberAddress = members[pubkey];
        require(memberAddress != address(0), "Member doesn't exist");

        delete members[pubkey];

        return memberAddress;
    }
}
