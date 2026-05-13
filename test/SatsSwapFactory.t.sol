// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SatsSwapFactory} from "../src/SatsSwapFactory.sol";
import {SatsSwapPair} from "../src/SatsSwapPair.sol";
import {MockBTC} from "../src/MockBTC.sol";
import {MockETH} from "../src/MockETH.sol";

contract SatsSwapFactoryTest is Test {
    SatsSwapFactory factory;
    MockBTC btc;
    MockETH eth;

    function setUp() public {
        // Deploy the Manager (Factory) and the "Tokens"
        factory = new SatsSwapFactory();
        btc = new MockBTC();
        eth = new MockETH();
    }

    function test_CreatePair() public {
        // Tell the factory to create a pair for BTC and ETH
        address pairAddress = factory.createPair(address(btc), address(eth));

        // 1. Verify the address is NOT empty
        assertTrue(pairAddress != address(0), "Pair address should not be zero");

        // 2. Check if the Factory remembers this pair
        address storedAddress = factory.getPair(address(btc), address(eth));
        assertEq(pairAddress, storedAddress, "Factory should store the correct pair address");

        // 3. Verify the Factory's list grew to 1
        uint256 totalPairs = factory.allPairsLength();
        assertEq(totalPairs, 1, "Total pairs should be 1");

        console.log("-----------------------");
        console.log("FACTORY TEST: SUCCESS");
        console.log("New BTC/ETH Pair Created at:", pairAddress);
        console.log("-----------------------");
    }

    function test_CannotCreateDuplicatePair() public {
        // Create it the first time
        factory.createPair(address(btc), address(eth));

        // Try to create it again - this should FAIL (Revert)
        // We use vm.expectRevert to tell Foundry "we expect this to break"
        vm.expectRevert("SatsSwap: PAIR_EXISTS");
        factory.createPair(address(btc), address(eth));

        console.log("Duplicate protection: WORKING");
    }
}
