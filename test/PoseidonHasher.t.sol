// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "../src/PoseidonHasher.sol";

contract PoseidonHasherTest is Test {
    PoseidonHasher public poseidonHasher;

    function setUp() public {
        poseidonHasher = new PoseidonHasher();
    }

    function testIdentity() public {
        assertEq(poseidonHasher.identity(), 0x2a09a9fd93c590c26b91effbb2499f07e8f7aa12e2b4940a3aed2411cb65e11c);
    }

    function testHash() public {
        assertEq(
            poseidonHasher.hash(19014214495641488759237505126948346942972912379615652741039992445865937985820),
            0x0c3ac305f6a4fe9bfeb3eba978bc876e2a99208b8b56c80160cfb54ba8f02368
        );
    }
}
