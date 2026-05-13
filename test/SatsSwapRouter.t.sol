// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {SatsSwapFactory} from "../src/SatsSwapFactory.sol";
import {SatsSwapRouter} from "../src/SatsSwapRouter.sol";
import {SatsSwapPair} from "../src/SatsSwapPair.sol";
import {MockBTC} from "../src/MockBTC.sol";
import {MockETH} from "../src/MockETH.sol";

contract SatsSwapRouterTest is Test {
    SatsSwapFactory factory;
    SatsSwapRouter router;
    MockBTC btc;
    MockETH eth;

    function setUp() public {
        factory = new SatsSwapFactory();
        router = new SatsSwapRouter(address(factory));
        btc = new MockBTC();
        eth = new MockETH();

        // Create the official pair via the Factory
        factory.createPair(address(btc), address(eth));

        // Give the test user some money
        btc.mint(address(this), 100 ether);
        eth.mint(address(this), 100 ether);
    }

    function test_FullSystemSwap() public {
        address pairAddress = factory.getPair(address(btc), address(eth));

        // --- ADD INITIAL LIQUIDITY ---
        btc.approve(address(pairAddress), 10 ether);
        eth.approve(address(pairAddress), 10 ether);
        SatsSwapPair(pairAddress).addLiquidity(10 ether, 10 ether);

        // --- THE ROUTER SWAP ---
        uint256 amountIn = 1 ether;

        // User only has to approve the ROUTER
        btc.approve(address(router), amountIn);

        uint256 amountOut = router.swapExactTokensForTokens(
            address(btc),
            address(eth),
            amountIn
        );

        console.log("-----------------------");
        console.log("FULL SYSTEM TEST: SUCCESS");
        console.log("Input: 1 BTC");
        console.log("Output Wei:", amountOut);
        console.log("-----------------------");

        assertTrue(amountOut > 0, "Router should return tokens");
    }
}
