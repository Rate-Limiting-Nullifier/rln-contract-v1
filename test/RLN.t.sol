// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/RLN.sol";
import "../src/PoseidonHasher.sol";

contract RlnTest is Test {
    RLN public rln;
    PoseidonHasher public poseidonHasher;

    event MemberRegistered(uint256 pubkey, uint256 index);
    event MemberWithdrawn(uint256 pubkey);

    function setUp() public {
        poseidonHasher = new PoseidonHasher();
        rln = new RLN(1000000000000000, 20, address(poseidonHasher));
    }

    function testRegistration() public {
        uint256 price = rln.MEMBERSHIP_DEPOSIT();

        uint256 id_secret = 0x2a09a9fd93c590c26b91effbb2499f07e8f7aa12e2b4940a3aed2411cb65e11c;
        uint256 id_commitment = 0x0c3ac305f6a4fe9bfeb3eba978bc876e2a99208b8b56c80160cfb54ba8f02368;

        // Registration
        vm.expectEmit(false, false, false, true, address(rln));
        emit MemberRegistered(id_commitment, 0);
        rln.register{value: price}(id_commitment);

        // Withdraw
        address receiverAddress = 0x000000000000000000000000000000000000dEaD;

        vm.expectEmit(false, false, false, true, address(rln));
        emit MemberWithdrawn(id_commitment);
        rln.withdraw(id_secret, payable(receiverAddress));

        // Check index update
        assertEq(rln.pubkeyIndex(), 1);
    }

    function testFailDupeRegistration() public {
        uint256 price = rln.MEMBERSHIP_DEPOSIT();

        uint256 id_commitment = 0x0c3ac305f6a4fe9bfeb3eba978bc876e2a99208b8b56c80160cfb54ba8f02368;

        // First registration
        rln.register{value: price}(id_commitment);

        // Second registration // Should revert
        rln.register{value: price}(id_commitment);
    }
}
