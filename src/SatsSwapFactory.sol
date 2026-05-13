// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {SatsSwapPair} from "./SatsSwapPair.sol";

contract SatsSwapFactory {
    // This map lets us look up a pair address using two token addresses
    // getPair[tokenA][tokenB] = pairAddress
    mapping(address => mapping(address => address)) public getPair;

    // An array to keep track of ALL pairs created for easy listing
    address[] public allPairs;

    // This event tells the outside world (like a website) that a new pair exists
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, "SatsSwap: IDENTICAL_ADDRESSES");
        require(tokenA != address(0) && tokenB != address(0), "SatsSwap: ZERO_ADDRESS");
        require(getPair[tokenA][tokenB] == address(0), "SatsSwap: PAIR_EXISTS");

        // We deploy a new copy of our Pair contract
        // This is the "Modular" magic—one blueprint, many instances
        pair = address(new SatsSwapPair(tokenA, tokenB));

        // We store the address in our maps (both ways so order doesn't matter)
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
        allPairs.push(pair);

        emit PairCreated(tokenA, tokenB, pair, allPairs.length);
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }
}
