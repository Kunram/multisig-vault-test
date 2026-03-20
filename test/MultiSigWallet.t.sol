pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MultiSigWallet.sol";

contract MultiSigWalletTest is Test {
    MultiSigWallet public wallet;
    
    // define 3 test accounts
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public carol = address(0x3);
    address public nonOwner = address(0x4);

    address[] public owners;

    // Initialize
    function setUp() public {
        owners.push(alice);
        owners.push(bob);
        owners.push(carol);

        wallet = new MultiSigWallet(owners, 2);
        
        vm.deal(address(wallet), 10 ether); 
    }

    // Happy Path
    function testSubmitAndExecuteTransaction() public {
        address receiver = address(0x5);
        uint amount = 1 ether;
        bytes memory data = ""; 


        vm.prank(alice); 
        wallet.submitTransaction(receiver, amount, data);


        vm.prank(alice);
        wallet.confirmTransaction(0);


        vm.prank(bob);
        wallet.confirmTransaction(0);


        vm.prank(bob);
        wallet.executeTransaction(0);


        assertEq(receiver.balance, amount);
    }

    // Security & Revert Cases
    function testRevertWhenNotOwnerSubmits() public {
        vm.expectRevert("Not an owner");
        
        vm.prank(nonOwner);
        wallet.submitTransaction(address(0x5), 1 ether, "");
    }

    function testRevertExecuteBeforeConfirmations() public {
        vm.prank(alice);
        wallet.submitTransaction(address(0x5), 1 ether, "");
        vm.prank(alice);
        wallet.confirmTransaction(0);

        vm.expectRevert("Cannot execute: confirmations not reached");
        
        vm.prank(alice);
        wallet.executeTransaction(0);
    }
}
