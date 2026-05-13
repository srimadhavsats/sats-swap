// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// We use the interface to talk to the token contracts
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
     * @dev ADD LIQUIDITY: Now actually pulls tokens from the user.
     */
    function addLiquidity(uint256 amountBTC, uint256 amountETH) external {
        // First, we pull the tokens from the user's wallet into this contract
        IERC20(btcToken).transferFrom(msg.sender, address(this), amountBTC);
        IERC20(ethToken).transferFrom(msg.sender, address(this), amountETH);

        if (reserveBTC == 0 && reserveETH == 0) {
            reserveBTC = amountBTC;
            reserveETH = amountETH;
        } else {
            uint256 expectedETH = (reserveETH * amountBTC) / reserveBTC;
            require(amountETH >= expectedETH, "Ratio must match current reserves");

            reserveBTC += amountBTC;
            reserveETH += amountETH;
        }
    }

    /**
     * @dev SWAP: Now pulls the input token and sends the output token.
     */
    function swap(address tokenIn, uint256 amountIn) external returns (uint256 amountOut) {
        require(tokenIn == btcToken || tokenIn == ethToken, "Invalid token");

        bool isBTC = tokenIn == btcToken;
        address tokenOut = isBTC ? ethToken : btcToken;

        (uint256 reserveIn, uint256 reserveOut) = isBTC
            ? (reserveBTC, reserveETH)
            : (reserveETH, reserveBTC);

        // Calculate the math
        amountOut = (reserveOut * amountIn) / (reserveIn + amountIn);

        // 1. Pull the user's tokens into the vault
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // 2. Update our internal accounting
        if (isBTC) {
            reserveBTC += amountIn;
            reserveETH -= amountOut;
        } else {
            reserveETH += amountIn;
            reserveBTC -= amountOut;
        }

        // 3. Send the exchanged tokens to the user
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        return amountOut;
    }

    function getReserves() public view returns (uint256, uint256) {
        return (reserveBTC, reserveETH);
    }
}
