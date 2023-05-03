// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../src/RLN.sol";

contract RLNScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // RLN rln = new RLN(vm.envUint("STAKE"), vm.envUint("DEPTH"), address(poseidonHasher));

        vm.stopBroadcast();
    }
}
