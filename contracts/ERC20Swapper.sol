// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC20Swapper.sol";


contract ERC20Swapper is Initializable, IERC20Swapper {

    address internal _owner;
    // https://ropsten.etherscan.io/address/0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    address private constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    // https://docs.openzeppelin.com/upgrades-plugins/1.x/writing-upgradeable
    function initialize() public initializer {
        _owner = msg.sender;
    }


    function swapEtherToToken(address token, uint minAmount) public override payable returns (uint){

        //https://docs.uniswap.org/protocol/V2/guides/smart-contract-integration/trading-from-a-smart-contract
        require(IERC20(token).transferFrom(msg.sender, address(this), minAmount), 'transferFrom failed.');
        require(IERC20(token).approve(UNISWAP_V2_ROUTER, minAmount), 'approve failed.');

        // fetch address via router > default ropsten uni router
        IUniswapV2Router02 router = IUniswapV2Router02(UNISWAP_V2_ROUTER);
        address weth = router.WETH();
        // canonical WETH address
        IUniswapV2Factory factory = IUniswapV2Factory(router.factory());

        // @dev swaps the `msg.value` Ether to at least `minAmount` of tokens in `address`, or reverts
        // Current request ETH swap to "Token"
        address pair = factory.getPair(token, weth);
        require(pair != address(0), "Invalid UNI Pairs");
        // Check for valid pair in
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = token;

        //swapExactETHForTokens
        //for the deadline we will pass in block.timestamp
        //the deadline is the latest time the trade is valid for
        // uint[] memory = [whetAmount, tokenAmount]
        // swapExactETHForTokens can be done using pair.swap and some logic to improve perf..
        return router.swapExactETHForTokens{value : msg.value}(minAmount, path, msg.sender, block.timestamp)[1];
    }
}
