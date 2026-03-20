pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/MultiSigWallet.sol";

contract DeployMultiSig is Script {
    function run() external {
        // test sk not for real
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // initialize
        address[] memory initialOwners = new address[](3);
        initialOwners[0] = address(0x111...); 
        initialOwners[1] = address(0x222...);
        initialOwners[2] = address(0x333...);

        MultiSigWallet wallet = new MultiSigWallet(initialOwners, 2);

        vm.stopBroadcast();
    }
}
