// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SatsSwapPair} from "../src/SatsSwapPair.sol";
import {MockBTC} from "../src/MockBTC.sol";
import {MockETH} from "../src/MockETH.sol";

contract SatsSwapTest is Test {
    SatsSwapPair pair;
    MockBTC btc;
    MockETH eth;

    function setUp() public {
        btc = new MockBTC();
        eth = new MockETH();
        pair = new SatsSwapPair(address(btc), address(eth));

        // Give this test contract some "fake" money to play with
        btc.mint(address(this), 100 ether);
        eth.mint(address(this), 1000 ether);
    }

    function test_LiquidityAndSwapWithTransfers() public {
        uint256 initialBTC = 10 ether;
        uint256 initialETH = 150 ether;

        // --- THE CRITICAL STEP: APPROVE ---
        // We tell the tokens: "It's okay for the Pair contract to take my money"
        btc.approve(address(pair), initialBTC);
        eth.approve(address(pair), initialETH);

        // Now add liquidity (this calls transferFrom internally)
        pair.addLiquidity(initialBTC, initialETH);

        // --- TEST THE SWAP ---
        uint256 swapAmount = 1 ether;

        // Approve the pair to take 1 BTC for the swap
        btc.approve(address(pair), swapAmount);

        uint256 btcBefore = btc.balanceOf(address(this));
        uint256 ethBefore = eth.balanceOf(address(this));

        uint256 amountOut = pair.swap(address(btc), swapAmount);

        // Verify balances changed correctly
        assertEq(btc.balanceOf(address(this)), btcBefore - swapAmount);
        assertEq(eth.balanceOf(address(this)), ethBefore + amountOut);

        console.log("-----------------------");
        console.log("SWAP SUCCESSFUL");
        console.log("Tokens actually moved!");
        console.log("ETH Received:", amountOut / 1e15, " (scaled)");
        console.log("-----------------------");
    }
}
