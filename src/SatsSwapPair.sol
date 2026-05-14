// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SatsSwapPair
 * @author srimadhavsats
 * @notice Core contract for a single token pair vault in the Sats Swap DEX.
 * @dev Implements the constant product formula $x * y = k$ and handles token transfers.
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract SatsSwapPair {
    address public btcToken;
    address public ethToken;

    uint256 public reserveBTC;
    uint256 public reserveETH;

    /**
     * @notice Initializes the pair with two token addresses.
     * @param _btc The address of the first token (MockBTC).
     * @param _eth The address of the second token (MockETH).
     */
    constructor(address _btc, address _eth) {
        btcToken = _btc;
        ethToken = _eth;
    }

    /**
     * @notice Adds initial or additional liquidity to the pool.
     * @dev Liquidity must be added in the correct ratio unless the pool is empty.
     * @param amountBTC The amount of BTC to deposit.
     * @param amountETH The amount of ETH to deposit.
     */
    function addLiquidity(uint256 amountBTC, uint256 amountETH) external {
        require(
            IERC20(btcToken).transferFrom(msg.sender, address(this), amountBTC),
            "SatsSwap: BTC_TRANSFER_FAILED"
        );
        require(
            IERC20(ethToken).transferFrom(msg.sender, address(this), amountETH),
            "SatsSwap: ETH_TRANSFER_FAILED"
        );

        if (reserveBTC == 0 && reserveETH == 0) {
            reserveBTC = amountBTC;
            reserveETH = amountETH;
        } else {
            // Formula: $\Delta y = \frac{y \cdot \Delta x}{x}$
            uint256 expectedETH = (reserveETH * amountBTC) / reserveBTC;
            require(amountETH >= expectedETH, "SatsSwap: INSUFFICIENT_ETH_AMOUNT");

            reserveBTC += amountBTC;
            reserveETH += amountETH;
        }
    }

    /**
     * @notice Swaps one token for another using the AMM formula.
     * @dev Calculation is based on the formula: $\Delta y = \frac{y \cdot \Delta x}{x + \Delta x}$
     * @param tokenIn The address of the token being provided by the user.
     * @param amountIn The amount of tokenIn being sent.
     * @return amountOut The amount of the other token sent to the user.
     */
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == btcToken || tokenIn == ethToken, "SatsSwap: INVALID_TOKEN");

        bool isBTC = tokenIn == btcToken;
        address tokenOut = isBTC ? ethToken : btcToken;

        (uint256 reserveIn, uint256 reserveOut) = isBTC
            ? (reserveBTC, reserveETH)
            : (reserveETH, reserveBTC);

        amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);

        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "SatsSwap: TRANSFER_IN_FAILED"
        );

        if (isBTC) {
            reserveBTC += amountIn;
            reserveETH -= amountOut;
        } else {
            reserveETH += amountIn;
            reserveBTC -= amountOut;
        }

        require(
            IERC20(tokenOut).transfer(msg.sender, amountOut),
            "SatsSwap: TRANSFER_OUT_FAILED"
        );

        return amountOut;
    }

    /**
     * @notice Utility function to fetch the current pool reserves.
     * @return (uint256, uint256) Current BTC and ETH reserves.
     */
    function getReserves() public view returns (uint256, uint256) {
        return (reserveBTC, reserveETH);
    }
}
