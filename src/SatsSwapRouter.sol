// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SatsSwapFactory} from "./SatsSwapFactory.sol";
import {SatsSwapPair} from "./SatsSwapPair.sol";

interface IERC20 {
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

contract SatsSwapRouter {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    /**
     * @dev High-level Swap: The Router finds the pair and handles the logic.
     */
    function swapExactTokensForTokens(address tokenIn, address tokenOut, uint256 amountIn)
        external
        returns (uint256 amountOut)
    {
        // 1. Find the specific vault (pair) from the factory
        address pair = SatsSwapFactory(factory).getPair(tokenIn, tokenOut);
        require(pair != address(0), "SatsSwapRouter: PAIR_NOT_FOUND");

        // 2. Pull the tokens from the user to the Router
        require(IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn), "SatsSwapRouter: TRANSFER_IN_FAILED");

        // 3. Approve the Pair to take the tokens from the Router
        IERC20(tokenIn).approve(pair, amountIn);

        // 4. Call the swap on the Pair
        amountOut = SatsSwapPair(pair).swap(tokenIn, amountIn);
    }
}
