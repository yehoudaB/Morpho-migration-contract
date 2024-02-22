// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IMorphoFlashLoanCallback} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {MarketParams} from "@morpho-blue/interfaces/IMorpho.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {console} from "forge-std/console.sol";

contract MigrateAaveV3OptimizerToBlue is IMorphoFlashLoanCallback, ReentrancyGuard {
    IMorpho private immutable MORPHO;
    AaveV3Optimizer constant private aaveV3Optimizer  =  AaveV3Optimizer(0x33333aea097c193e66081E930c33020272b33333);
    uint256 private  shares;

    constructor(address _morpho) {
        MORPHO = IMorpho(_morpho);
    }

    


    function migrate(
        address user,
        MarketParams memory marketParams,
        address[] calldata userSuppliedAssets,
        uint256[] calldata userSuppliedAmounts,
        uint128 suppliedAssetIndexThatIsBlueCollateral,
        address userBorrowedAsset,
        uint256 userBorrowedAmount
    ) external nonReentrant {
        bytes memory data = abi.encode(
            user,
            marketParams,
            userSuppliedAssets,
            userSuppliedAmounts,
            suppliedAssetIndexThatIsBlueCollateral,
            userBorrowedAmount
        );
        flashLoan(userBorrowedAsset, userBorrowedAmount, data);
    }

    function flashLoan(address token, uint256 assets, bytes memory data) private {
        MORPHO.flashLoan(token, assets, data);
    }

    function onMorphoFlashLoan(uint256 assets, bytes memory data) external {
        require(msg.sender == address(MORPHO));
        (
            address user,
            MarketParams memory marketParams,
            address[] memory userSuppliedAssets,
            uint256[] memory userSuppliedAmounts,
            uint128 suppliedAssetIndexThatIsBlueCollateral,
            uint256 borrowedAmount
        ) = abi.decode(data, (address, MarketParams, address[], uint256[], uint128, uint256));

       
        if(IERC20(marketParams.loanToken).allowance(address(this), address(aaveV3Optimizer)) < assets){
            IERC20(marketParams.loanToken).approve(address(aaveV3Optimizer), type(uint256).max);
            IERC20(marketParams.loanToken).approve(address(MORPHO), type(uint256).max);
        }
        if(IERC20(marketParams.collateralToken).allowance(address(this), address(MORPHO)) < assets){
            IERC20(marketParams.collateralToken).approve(address(MORPHO), type(uint256).max);
        }
      

        aaveV3Optimizer.repay(marketParams.loanToken, assets, user);
        for (uint256 i = 0; i < userSuppliedAssets.length; i++) {
            aaveV3Optimizer.withdrawCollateral(userSuppliedAssets[i], userSuppliedAmounts[i], user, address(this));
        }
        

        MORPHO.supplyCollateral(marketParams, userSuppliedAmounts[suppliedAssetIndexThatIsBlueCollateral], user, hex"");

        MORPHO.borrow(marketParams, borrowedAmount, shares, user, address(this));
        
    }
   
    function getUserInfo(address user, address blueCollateralAddress)
        external
        view
        returns (
            address[] memory userSuppliedAssets,
            uint256[] memory userSuppliedAmounts,
            uint128 suppliedAssetIndexThatIsBlueCollateral,
            address[] memory userBorrowedAsset,
            uint256[] memory userBorrowedAmounts
        ) {

        userSuppliedAssets = aaveV3Optimizer.userCollaterals(user);
        userBorrowedAsset = aaveV3Optimizer.userBorrows(user);
        userSuppliedAmounts = new uint256[](userSuppliedAssets.length);
        userBorrowedAmounts = new uint256[](userBorrowedAsset.length);
        suppliedAssetIndexThatIsBlueCollateral;
        for (uint128 i = 0; i < userSuppliedAssets.length; i++) {
            if (userSuppliedAssets[i] == blueCollateralAddress) {
                suppliedAssetIndexThatIsBlueCollateral = i;
            }
            userSuppliedAmounts[i] = aaveV3Optimizer.collateralBalance(userSuppliedAssets[i], user);
        }

        for (uint256 i = 0; i < userBorrowedAsset.length; i++) {
            userBorrowedAmounts[i] = aaveV3Optimizer.borrowBalance(userBorrowedAsset[i], user);
        }

        return (
            userSuppliedAssets,
            userSuppliedAmounts,
            suppliedAssetIndexThatIsBlueCollateral,
            userBorrowedAsset,
            userBorrowedAmounts
        );
    }
}
