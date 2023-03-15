// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IGroupStorage {
    function set(uint256, address) external;
    function remove(uint256) external;
    function members(uint256) external view returns (address);
}

contract GroupStorage is IGroupStorage, Ownable {
    mapping(uint256 => address) public members;

    function set(uint256 pubkey, address value) external onlyOwner {
        members[pubkey] = value;
    }

    function remove(uint256 pubkey) external onlyOwner {
        delete members[pubkey];
    }
}
