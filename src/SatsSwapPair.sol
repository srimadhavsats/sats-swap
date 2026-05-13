// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

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
     * @dev ADD LIQUIDITY: Now with transfer verification.
     */
    function addLiquidity(uint256 amountBTC, uint256 amountETH) external {
        // We wrap the transfer in require() to ensure it returns 'true'
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
            uint256 expectedETH = (reserveETH * amountBTC) / reserveBTC;
            require(amountETH >= expectedETH, "SatsSwap: INSUFFICIENT_ETH_AMOUNT");

            reserveBTC += amountBTC;
            reserveETH += amountETH;
        }
    }

    /**
     * @dev SWAP: Now with transfer verification.
     */
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == btcToken || tokenIn == ethToken, "SatsSwap: INVALID_TOKEN");

        bool isBTC = tokenIn == btcToken;
        address tokenOut = isBTC ? ethToken : btcToken;

        (uint256 reserveIn, uint256 reserveOut) = isBTC
            ? (reserveBTC, reserveETH)
            : (reserveETH, reserveBTC);

        amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);

        // 1. Pull tokens and check success
        require(
            IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn),
            "SatsSwap: TRANSFER_IN_FAILED"
        );

        // 2. Update accounting
        if (isBTC) {
            reserveBTC += amountIn;
            reserveETH -= amountOut;
        } else {
            reserveETH += amountIn;
            reserveBTC -= amountOut;
        }

        // 3. Send tokens and check success
        require(
            IERC20(tokenOut).transfer(msg.sender, amountOut),
            "SatsSwap: TRANSFER_OUT_FAILED"
        );

        return amountOut;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveBTC, reserveETH);
    }
}
