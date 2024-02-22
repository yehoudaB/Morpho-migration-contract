// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {WETH} from "@mySrc/WETH.sol";
import {MorphoBlueSnippets} from "@morpho-blue-snippets/morpho-blue/MorphoBlueSnippets.sol";
import {MarketParams} from "@morpho-blue/interfaces/IMorpho.sol";
import {IMorpho, Id} from "@morpho-blue/interfaces/IMorpho.sol";
import {MigrateAaveV3OptimizerToBlue} from "@mySrc/MigrateToBlue.sol";
import {DeployMigrateToBlue} from "./DeployMigrateToBlue.s.sol";

contract InteractWithMigrateToBlue is Script {
    address constant WETH_address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant chainlinkOracle_wstETH_wETH = 0x2a01EB9496094dA03c4E364Def50f5aD1280AD72;
    address constant adaptativeCurveIrm = 0x870aC11D48B15DB9a138Cf899d20F13F79Ba00BC;
    address constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    //Id constant wstETH_wETH_marketId  = 0xc54d7acf14de29e0e5527cabd7a576506870346a78a11a6762e2cca66322ec41;
    uint256 constant loanToValue_wstETH_wETH = 945000000000000000;

    //////////////////////////////////////////
    // update this address with the address of the user you want to interact with
    address user = 0x04Fb136989106430e56F24c3d6A473488235480E;
    //////////////////////////////////////////

    function run() public {
        DeployMigrateToBlue deployMigrateToBlue = new DeployMigrateToBlue();
        (address aaveV3OptimizerAddress, address morphoAddress, address migrateAaveV3OptimizerToBlueAddress) =
            deployMigrateToBlue.getConfig();
        MigrateAaveV3OptimizerToBlue migrateAaveV3OptimizerToBlue =
            MigrateAaveV3OptimizerToBlue(migrateAaveV3OptimizerToBlueAddress);

        address a = address(migrateAaveV3OptimizerToBlue);
        console.log("a", a);

        MarketParams memory marketParams = MarketParams({
            loanToken: WETH_address,
            collateralToken: WSTETH,
            oracle: chainlinkOracle_wstETH_wETH,
            irm: adaptativeCurveIrm,
            lltv: loanToValue_wstETH_wETH
        });
        console.log("opt");
    }
}
