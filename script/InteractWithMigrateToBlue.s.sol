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
    

    function run() public {
        DeployMigrateToBlue deployMigrateToBlue;
        (, , address migrateAaveV3OptimizerToBlueAddress) = deployMigrateToBlue.getConfig();
        MigrateAaveV3OptimizerToBlue migrateAaveV3OptimizerToBlue = MigrateAaveV3OptimizerToBlue(migrateAaveV3OptimizerToBlueAddress);
        
        migrateAaveV3OptimizerToBlue.migrate();

        
    }

}