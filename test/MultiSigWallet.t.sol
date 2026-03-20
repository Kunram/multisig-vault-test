// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {MultiSigWallet} from "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet wallet;
    
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    address owner3 = address(0x3);
    address attacker = address(0x4);
    address receiver = address(0x5);

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSigWallet(owners, 2);
        vm.deal(address(wallet), 10 ether); 
    }

    function test_ExecutionFlow() public {
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");

        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.confirmTransaction(0);

        vm.prank(owner2);
        wallet.executeTransaction(0);

        assertEq(receiver.balance, 1 ether);
    }

    function test_RevertWhen_UnauthorizedSubmit() public {
        vm.prank(attacker);
        vm.expectRevert(MultiSigWallet.NotOwner.selector);
        wallet.submitTransaction(receiver, 1 ether, "");
    }

    function test_RevertWhen_ExecuteBelowQuorum() public {
        vm.prank(owner1);
        wallet.submitTransaction(receiver, 1 ether, "");
        
        vm.prank(owner1);
        wallet.confirmTransaction(0);

        vm.prank(owner1);
        vm.expectRevert(MultiSigWallet.QuorumNotReached.selector);
        wallet.executeTransaction(0);
    }
}
