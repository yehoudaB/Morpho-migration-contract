// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Morpho as AaveV3Optimizer} from "@morpho-aavev3-optimizer/src/Morpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {WETH} from "@morpho-aavev3-optimizer/lib/solmate/src/tokens/WETH.sol";
import {MorphoBlueSnippets} from "@morpho-blue-snippets/morpho-blue/MorphoBlueSnippets.sol";

contract TestMorphoTransfer is Test {
    using SafeERC20 for IERC20;
    AaveV3Optimizer public aaveV3Optimizer;
   
    MorphoBlueSnippets public morphoBlueSnippets;
    address constant USER_1 = 0x0FACEC34a25bE20Fd8DCe63DB46cf902378D44f1; // wsteth depositor in aaveV3optimizer
    address constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    
    
    function setUp() public {
        aaveV3Optimizer =  AaveV3Optimizer(0x33333aea097c193e66081E930c33020272b33333);
        morphoBlueSnippets = MorphoBlueSnippets(0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb);
        address owner = aaveV3Optimizer.owner();
        console.log("Morpho owner: %s", owner);
        
        vm.deal(USER_1, 100 ether);
    }

    /**
     * @notice Test Withdrawing WSTETH into AaveV3Optimizer
     * @dev User must have deposited WSTETH into AaveV3Optimizer AND have enough health factor to withdraw 1 WSTETH
     */
    function testWithdrawWstETH_v3Optimizer() public {
        uint256 wstETHBalanceBefore = aaveV3Optimizer.collateralBalance(WSTETH, USER_1);
        console.log("wstETHBalanceBefore: %s", wstETHBalanceBefore);
        vm.startBroadcast(USER_1);
        uint256 amountWithdrawn =  aaveV3Optimizer.withdrawCollateral(WSTETH, 1 ether, USER_1, USER_1);
        vm.stopBroadcast();
        console.log("amountWithdrawn: %s", amountWithdrawn);
        uint256 wstETHBalanceAfter = aaveV3Optimizer.collateralBalance( WSTETH, USER_1);
        console.log("wstETHBalanceAfter: %s", wstETHBalanceAfter);
        assertEq(wstETHBalanceAfter, wstETHBalanceBefore - 1 ether);
    }

    /**
     * @notice Test repay WETH to AaveV3Optimizer
     *
     */
    function testRepayWETH_v3Optimizer() public {
        vm.startBroadcast(USER_1);
        // wrap ETH to WETH
        WETH(payable (WETH_address)).deposit{value: 1 ether}();
        IERC20(WETH_address).approve(address(aaveV3Optimizer), 1 ether);
        // balance of WETH in AaveV3Optimizer
        uint256 balanceWETH = IERC20(WETH_address).balanceOf(address(USER_1));
        console.log("balanceWETH: %s", balanceWETH);
        uint256 amountRepayed =  aaveV3Optimizer.repay(WETH_address, 1 ether, USER_1);
        vm.stopBroadcast();
        console.log("amountRepayed: %s", amountRepayed);
       
    }

    function testDeposit_blue() public {
        
    }

    
    
}
