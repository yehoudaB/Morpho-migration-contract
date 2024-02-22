// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {WETH} from "@mySrc/WETH.sol";
import {MorphoBlueSnippets} from "@morpho-blue-snippets/morpho-blue/MorphoBlueSnippets.sol";
import {MarketParams} from "@morpho-blue/interfaces/IMorpho.sol";
import {IMorpho, Id} from "@morpho-blue/interfaces/IMorpho.sol";
import {MigrateAaveV3OptimizerToBlue} from "@mySrc/MigrateToBlue.sol";
import {DeployMigrateToBlue} from "../script/DeployMigrateToBlue.s.sol";
contract TestMorphoTransfer is Test {
    using SafeERC20 for IERC20;

    AaveV3Optimizer public aaveV3Optimizer;
    IMorpho public morphoBlue;
    MigrateAaveV3OptimizerToBlue public migrateAaveV3OptimizerToBlue;
    DeployMigrateToBlue public deployMigrateToBlue;   
    address constant USER_1 = 0x04Fb136989106430e56F24c3d6A473488235480E; // wsteth depositor in aaveV3optimizer
    address constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address constant chainlinkOracle_wstETH_wETH = 0x2a01EB9496094dA03c4E364Def50f5aD1280AD72;
    address constant adaptativeCurveIrm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
    //Id constant wstETH_wETH_marketId  = 0xc54d7acf14de29e0e5527cabd7a576506870346a78a11a6762e2cca66322ec41;
    uint256 constant loanToValue_wstETH_wETH = 945000000000000000;

    function setUp() public {
        deployMigrateToBlue = new DeployMigrateToBlue();
           (address aaveV3OptimizerAddress, address morphoAddress, address  deployedMigrateAaveV3OptimizerToBlueAddress) 
           = deployMigrateToBlue.getConfig();
        
        vm.startBroadcast();
        migrateAaveV3OptimizerToBlue = new MigrateAaveV3OptimizerToBlue(morphoAddress);
        vm.stopBroadcast(); 
     
        aaveV3Optimizer = AaveV3Optimizer(aaveV3OptimizerAddress);
        morphoBlue = IMorpho(morphoAddress);
        
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
        uint256 amountWithdrawn = aaveV3Optimizer.withdrawCollateral(WSTETH, 1 ether, USER_1, USER_1);
        vm.stopBroadcast();
        console.log("amountWithdrawn: %s", amountWithdrawn);
        uint256 wstETHBalanceAfter = aaveV3Optimizer.collateralBalance(WSTETH, USER_1);
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
        WETH(payable(WETH_address)).deposit{value: 1 ether}();
        IERC20(WETH_address).approve(address(aaveV3Optimizer), 1 ether);
        // balance of WETH in AaveV3Optimizer
        uint256 balanceWETH = IERC20(WETH_address).balanceOf(address(USER_1));
        console.log("balanceWETH: %s", balanceWETH);
        uint256 amountRepayed = aaveV3Optimizer.repay(WETH_address, 1 ether, USER_1);
        vm.stopBroadcast();
        console.log("amountRepayed: %s", amountRepayed);
    }

    function testDeposit_blue() public {
        //MarketParams memory marketParams = morphoBlue.idToMarketParams(wstETH_wETH_marketId);

        MarketParams memory marketParams = MarketParams({
            loanToken: WETH_address,
            collateralToken: WSTETH,
            oracle: chainlinkOracle_wstETH_wETH,
            irm: adaptativeCurveIrm,
            lltv: loanToValue_wstETH_wETH
        });

        bytes memory data = hex"";
        vm.startBroadcast(USER_1);
        // withdraw 1 WSTETH from AaveV3Optimizer to have enough collateral to deposit
        aaveV3Optimizer.withdrawCollateral(WSTETH, 1 ether, USER_1, USER_1);

        IERC20(WSTETH).approve(address(morphoBlue), 1 ether);
        morphoBlue.supplyCollateral(marketParams, 1 ether, USER_1, data);
        vm.stopBroadcast();
    }

    function testMigration() public {
        uint256 userCollateralWstETH = aaveV3Optimizer.collateralBalance(WSTETH, USER_1);
        uint256 userCollateralUSDC = aaveV3Optimizer.collateralBalance(USDC, USER_1);
        uint256 userBorrow = aaveV3Optimizer.borrowBalance(WETH_address, USER_1);

        address[] memory userSuppliedAssets = new address[](2);
        userSuppliedAssets[0] = WSTETH;
        userSuppliedAssets[1] = USDC;
        uint256[] memory userSuppliedAmounts = new uint256[](2);
        userSuppliedAmounts[0] = userCollateralWstETH;
        userSuppliedAmounts[1] = userCollateralUSDC;
        MarketParams memory marketParams = MarketParams({
            loanToken: WETH_address,
            collateralToken: WSTETH,
            oracle: chainlinkOracle_wstETH_wETH,
            irm: adaptativeCurveIrm,
            lltv: loanToValue_wstETH_wETH
        });

        vm.startBroadcast(USER_1);

        aaveV3Optimizer.approveManager(address(migrateAaveV3OptimizerToBlue), true);
        morphoBlue.setAuthorization(address(migrateAaveV3OptimizerToBlue), true);
        migrateAaveV3OptimizerToBlue.migrate(
            USER_1,
            marketParams,
            userSuppliedAssets,
            userSuppliedAmounts,
            0, // WSTETH is the collateral
            WETH_address,
            userBorrow
        );

        vm.stopBroadcast();
    }

    function testGetUserInfo() public view {
        (
            address[] memory userSuppliedAssets,
            uint256[] memory userSuppliedAmounts,
            uint128 suppliedAssetIndexThatIsBlueCollateral,
            address[] memory userBorrowedAsset,
            uint256[] memory userBorrowedAmounts
        ) = migrateAaveV3OptimizerToBlue.getUserInfo(USER_1, WSTETH);
        
        for(uint256 i = 0; i < userSuppliedAssets.length; i++){
            console.log("userSuppliedAssets: ", ERC20(userSuppliedAssets[i]).symbol(), 
            "userSuppliedAmounts: ", userSuppliedAmounts[i]);
        }
        for(uint256 i = 0; i < userBorrowedAsset.length; i++){
            console.log("userBorrowedAsset:  ", ERC20(userBorrowedAsset[i]).symbol(),
             " userBorrowedAmounts: ", userBorrowedAmounts[i]);
        }
        console.log("suppliedAssetIndexThatIsBlueCollateral: ", suppliedAssetIndexThatIsBlueCollateral);
    }

    function testGetUserInfoWithDeployedMigrateToBlue() public view {
          (,, address  deployedMigrateAaveV3OptimizerToBlueAddress) 
           = deployMigrateToBlue.getConfig();
        
        MigrateAaveV3OptimizerToBlue alreadyDeployedMigrateAaveV3OptimizerToBlue = MigrateAaveV3OptimizerToBlue(
           deployedMigrateAaveV3OptimizerToBlueAddress
        );
        (
            address[] memory userSuppliedAssets,
            uint256[] memory userSuppliedAmounts,
            uint128 suppliedAssetIndexThatIsBlueCollateral,
            address[] memory userBorrowedAsset,
            uint256[] memory userBorrowedAmounts
        ) = alreadyDeployedMigrateAaveV3OptimizerToBlue.getUserInfo(USER_1, WSTETH);
    }

    


   
}


