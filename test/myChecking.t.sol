// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Test} from "forge-std/Test.sol";
import {MultiSigTimelock} from "src/MultiSigTimelock.sol";

contract myChecking is Test {
    MultiSigTimelock multisig;

    address owner = makeAddr("owner");
    address firstSigner = makeAddr("firstSigner");
    address secondSigner = makeAddr("secondSigner");
    address thirdSigner = makeAddr("thirdSigner");
    address fourthSinger = makeAddr("fourthSinger");
    address receipt = makeAddr("receiver");

    function setUp() public {
        vm.startBroadcast(owner);
        multisig = new MultiSigTimelock();
        multisig.grantSigningRole(firstSigner);
        multisig.grantSigningRole(secondSigner);
        multisig.grantSigningRole(thirdSigner);
        multisig.grantSigningRole(fourthSinger);

        deal(address(multisig), 1 ether);

        vm.stopBroadcast();
    }

    function test_revokeSinger() public {
        vm.prank(owner);
        uint256 transID = multisig.proposeTransaction(receipt, 1 ether, "");

        vm.prank(firstSigner);
        multisig.confirmTransaction(transID);

        vm.prank(secondSigner);
        multisig.confirmTransaction(transID);

        vm.prank(thirdSigner);
        multisig.confirmTransaction(transID);

        vm.prank(owner); // bug here even if theOwner revoke signingRole confirmation Of the user still count
        multisig.revokeSigningRole(firstSigner);

        vm.warp(block.timestamp + 25 hours);

        vm.prank(owner);
        multisig.executeTransaction(transID);
    }
}
