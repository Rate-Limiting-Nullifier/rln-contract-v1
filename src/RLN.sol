// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity 0.8.19;

import {IPoseidonHasher} from "./PoseidonHasher.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract RLN {
    using SafeERC20 for IERC20;

    uint256 public immutable MEMBERSHIP_DEPOSIT;
    uint256 public immutable DEPTH;
    uint256 public immutable SET_SIZE;

    address public immutable FEE_RECEIVER;

    // Fee percentage
    uint256 public immutable FEE;

    uint256 public pubkeyIndex = 0;
    mapping(uint256 => uint256) public members;

    IPoseidonHasher public poseidonHasher;
    IERC20 public token;

    event MemberRegistered(uint256 pubkey, uint256 index);
    event MemberWithdrawn(uint256 pubkey);

    constructor(uint256 membershipDeposit, uint256 depth, address _poseidonHasher, address token) {
        MEMBERSHIP_DEPOSIT = membershipDeposit;
        DEPTH = depth;
        SET_SIZE = 1 << depth;

        uint256 FEE_PERCENTAGE = 5;
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
        require(pubkeyIndex + pubkeylen <= SET_SIZE, "RLN, registerBatch: set is full");

        token.safeTransferFrom(msg.sender, address(this), MEMBERSHIP_DEPOSIT * pubkeyLen);
        for (uint256 i = 0; i < pubkeylen; i++) {
            _register(pubkeys[i]);
        }
    }

    function _register(uint256 pubkey) internal {
        require(members[pubkey] == 0, "RLN, register: pubkey already registered");

        members[pubkey] = MEMBERSHIP_DEPOSIT;

        emit MemberRegistered(pubkey, pubkeyIndex);
        pubkeyIndex += 1;
    }

    function withdrawBatch(uint256[] calldata secrets, address[] calldata receivers) external {
        uint256 batchSize = secrets.length;
        require(batchSize != 0, "RLN, withdrawBatch: batch size zero");
        require(batchSize == receivers.length, "RLN, withdrawBatch: batch size mismatch receivers");

        for (uint256 i = 0; i < batchSize; i++) {
            _withdraw(secrets[i], receivers[i]);
        }
    }

    function withdraw(uint256 secret, address receiver) external {
        _withdraw(secret, receiver);
    }

    function _withdraw(uint256 secret, address receiver) internal {
        uint256 pubkey = hash(secret);
        require(members[pubkey] != 0, "RLN, _withdraw: member doesn't exist");
        require(receiver != address(0), "RLN, _withdraw: empty receiver address");

        members[pubkey] = 0;

        token.safeTransfer(FEE_RECEIVER, FEE);
        token.safeTransfer(receiver, MEMBERSHIP_DEPOSIT - FEE);

        emit MemberWithdrawn(pubkey);
    }

    function hash(uint256 input) internal view returns (uint256) {
        return poseidonHasher.hash(input);
    }
}
