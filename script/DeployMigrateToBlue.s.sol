// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {MigrateAaveV3OptimizerToBlue} from "@mySrc/MigrateToBlue.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";

contract DeployMigrateToBlue is Script {
    address constant aaveV3OptimizerAddress = 0x33333aea097c193e66081E930c33020272b33333 ;
    address constant morphoAddress = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb ;

     // UPDATE AFTER EACH DEPLOYMENT with the run() function result
    address constant migrateAaveV3OptimizerToBlueAddress = 0xe86377FB53542b6a108f713c16903005986fc7c3;

    function run() external returns (MigrateAaveV3OptimizerToBlue migrateAaveV3OptimizerToBlue) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        AaveV3Optimizer aaveV3Optimizer = AaveV3Optimizer(aaveV3OptimizerAddress);
        IMorpho morpho = IMorpho(morphoAddress);
        migrateAaveV3OptimizerToBlue = new MigrateAaveV3OptimizerToBlue(
            morpho,
            aaveV3Optimizer
        );

        vm.stopBroadcast();
        return (migrateAaveV3OptimizerToBlue);
    }

   
    
    function getConfig() public pure returns (address, address, address) {
        return (aaveV3OptimizerAddress,  morphoAddress , migrateAaveV3OptimizerToBlueAddress);

    }
}
