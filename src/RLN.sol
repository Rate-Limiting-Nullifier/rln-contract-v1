// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.17;

import {IPoseidonHasher} from "./PoseidonHasher.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RLN {
    // ERC20 staking support
    using SafeERC20 for IERC20;

    uint256 public immutable MEMBERSHIP_DEPOSIT;
    uint256 public immutable DEPTH;
    uint256 public immutable SET_SIZE;

    // Address of fee receiver
    address public immutable FEE_RECEIVER;

    // Fee percentage
    uint256 public constant FEE_PERCENTAGE = 5;
    // Fee amount
    uint256 public immutable FEE;

    uint256 public pubkeyIndex = 0;
    mapping(uint256 => address) public members;

    IPoseidonHasher public poseidonHasher;
    IERC20 public token;

    event MemberRegistered(uint256 pubkey, uint256 index);
    event MemberSlashed(uint256 pubkey, address slasher);
    event MemberWithdrawn(uint256 pubkey);

    constructor(
        uint256 membershipDeposit,
        uint256 depth,
        address feeReceiver,
        address _poseidonHasher,
        address _token
    ) {
        MEMBERSHIP_DEPOSIT = membershipDeposit;
        DEPTH = depth;
        SET_SIZE = 1 << depth;

        FEE_RECEIVER = feeReceiver;
        FEE = FEE_PERCENTAGE * MEMBERSHIP_DEPOSIT / 100;

        poseidonHasher = IPoseidonHasher(_poseidonHasher);
        token = IERC20(_token);
    }

    function register(uint256 pubkey) external {
        require(pubkeyIndex < SET_SIZE, "RLN, register: set is full");

        token.safeTransferFrom(msg.sender, address(this), MEMBERSHIP_DEPOSIT);
        _register(pubkey);
    }

    function registerBatch(uint256[] calldata pubkeys) external {
        uint256 pubkeyLen = pubkeys.length;
        require(pubkeyIndex + pubkeyLen <= SET_SIZE, "RLN, registerBatch: set is full");

        token.safeTransferFrom(msg.sender, address(this), MEMBERSHIP_DEPOSIT * pubkeyLen);
        for (uint256 i = 0; i < pubkeyLen; i++) {
            _register(pubkeys[i]);
        }
    }

    function _register(uint256 pubkey) internal {
        // Make sure pubkey is not registered before
        require(members[pubkey] != address(0), "RLN, _register: pubkey already registered");

        members[pubkey] = msg.sender;
        emit MemberRegistered(pubkey, pubkeyIndex);
        pubkeyIndex += 1;
    }

    function withdraw(uint256 secret, address receiver) external {
        require(receiver != address(0), "RLN, withdraw: empty receiver address");
        uint256 pubkey = hash(secret);
        address _memberAddress = members[pubkey];
        require(_memberAddress != address(0), "RLN, withdraw: member doesn't exist");

        // If memberAddress == receiver, then withdraw money without a fee
        if (_memberAddress == receiver) {
            token.safeTransfer(receiver, MEMBERSHIP_DEPOSIT);
            emit MemberWithdrawn(pubkey);
        } else {
            token.safeTransfer(receiver, MEMBERSHIP_DEPOSIT - FEE);
            token.safeTransfer(FEE_RECEIVER, FEE);
            emit MemberSlashed(pubkey, receiver);
        }

        delete members[pubkey];
    }

    function hash(uint256 input) internal view returns (uint256) {
        return poseidonHasher.hash(input);
    }
}
