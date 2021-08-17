// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/IPeripheryImmutableState.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20Swapper.sol";


contract ERC20Swapper is Initializable, IERC20Swapper {
    error InvalidSwap();
    address internal _owner;
    address internal _wethAddress;
    address internal _factoryAddress;

    // https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable
    function initialize(IPeripheryImmutableState router) public initializer {
        _owner = msg.sender;
        _wethAddress = router.WETH9();
        _factoryAddress = router.factory();
    }

    // Uniswap v3 is offering three fee tiers: 0.05%, 0.30%, and 1.00%.
    function swapEtherToToken(address token, uint minAmount, uint16 fee) public override payable returns (uint outTokens){

        // @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
        // Current request ETH swap to "Token" get pools for WETH > Token
        // https://docs.uniswap.org/protocol/reference/core/UniswapV3Factory
        // https://docs.uniswap.org/protocol/reference/core/interfaces/IUniswapV3Factory
        IUniswapV3Factory factory = IUniswapV3Factory(_factoryAddress);
        // https://docs.uniswap.org/protocol/reference/core/UniswapV3Pool
        IUniswapV3Pool pool = IUniswapV3Pool(factory.getPool(_wethAddress, token, fee));
        require(pool != address(0), "Invalid UniSwap Pool for Pair");

        // Swap tokens
        // https://docs.uniswap.org/protocol/reference/core/UniswapV3Pool#swap
        // The delta of the balance of token1 of the pool, exact when negative, minimum when positive
        (,int256 amountToken) = pool.swap(
            address(this), // contract hold the tokens,
            true, //The direction of the swap, true for token0 to token1, false for token1 to token0
            int256(msg.value), // The amount of the swap
            0, // Ignore limits
            bytes [] // empty callback params
        );

        if (amountToken > 0 || uint(-amountToken) < minAmount) {
            revert InvalidSwap();
        }

        outTokens = amountToken;
    }
}
