// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IMorphoFlashLoanCallback} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MarketParams} from "@morpho-blue/interfaces/IMorpho.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {console} from "forge-std/console.sol";
contract MigrateAaveV3OptimizerToBlue  is IMorphoFlashLoanCallback , ReentrancyGuard  {
    
    IMorpho private immutable MORPHO;
    AaveV3Optimizer public aaveV3Optimizer;
    constructor(IMorpho _morpho, AaveV3Optimizer _aaveV3Optimizer) {
        MORPHO = _morpho;
        aaveV3Optimizer =  _aaveV3Optimizer;
    }

    function migrate(
        MarketParams memory marketParams,
        address[] calldata userSuppliedAssets,
        uint256[] calldata userSuppliedAmounts,
        address  userBorrowedAsset,
        uint256 userBorrowedAmount
        ) external nonReentrant {
        
        bytes memory data = abi.encode(marketParams, userSuppliedAssets, userSuppliedAmounts);
        flashLoan(userBorrowedAsset, userBorrowedAmount, data);

    }
    function flashLoan(address token, uint256 assets, bytes memory data)  public {
        MORPHO.flashLoan(token, assets, data);
    }

    function onMorphoFlashLoan(uint256 assets, bytes memory data) external  {
        require(msg.sender == address(MORPHO));
        address token = abi.decode(data, (address));
        console.log("token: %s", token);
        IERC20(token).approve(address(aaveV3Optimizer), assets);
        
        aaveV3Optimizer.repay(token, assets, 0x0FACEC34a25bE20Fd8DCe63DB46cf902378D44f1);
        aaveV3Optimizer.withdrawCollateral(token, assets, address(this), address(this));

        IERC20(token).approve(address(MORPHO), assets);
        
    }


}