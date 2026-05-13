// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MockBTC} from "./MockBTC.sol";
import {MockETH} from "./MockETH.sol";

contract SatsSwapPair {
    address public btcToken;
    address public ethToken;

    uint256 public reserveBTC;
    uint256 public reserveETH;

    constructor(address _btc, address _eth) {
        btcToken = _btc;
        ethToken = _eth;
    }

    /**
     * @dev THE MATH: Constant Product Formula (x * y = k)
     * This function calculates how much "Token B" you get for "Token A".
     */
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == btcToken || tokenIn == ethToken, "Invalid token address");
        require(amountIn > 0, "Must swap more than 0");

        // Identify which token is being "pushed" in and which is being "pulled" out
        bool isBTC = tokenIn == btcToken;
        (uint256 reserveIn, uint256 reserveOut) = isBTC
            ? (reserveBTC, reserveETH)
            : (reserveETH, reserveBTC);

        // AMM Formula: (reserveOut * amountIn) / (reserveIn + amountIn)
        // This ensures the vault stays balanced.
        amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);

        // Update the internal accounting (Reserves)
        if (isBTC) {
            reserveBTC += amountIn;
            reserveETH -= amountOut;
        } else {
            reserveETH += amountIn;
            reserveBTC -= amountOut;
        }

        return amountOut;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveBTC, reserveETH);
    }
}
