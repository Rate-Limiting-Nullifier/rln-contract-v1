// SPDX-License-Identifier: Apache-2.0 OR MIT
pragma solidity ^0.8.17;

interface IVerifier {
    function verifyProof(uint256 addressHash, uint256 identityCommitment, uint256[8] calldata proof)
        external
        view
        returns (bool);
}
