// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Script, console} from "forge-std/Script.sol";
import {Vm} from "forge-std/Vm.sol";
import {MigrateAaveV3OptimizerToBlue} from "@mySrc/MigrateToBlue.sol";
import {Morpho as AaveV3Optimizer} from "@morphoAave3Optimizer/src/Morpho.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";

contract DeployMigrateToBlue is Script {
    constructor() {
        getConfig();
    }
    address constant aaveV3OptimizerAddress = 0x33333aea097c193e66081E930c33020272b33333 ;
    address constant morphoAddress = 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb ;

     // UPDATE AFTER EACH DEPLOYMENT with the run() function result
    address constant migrateAaveV3OptimizerToBlueAddress = 0x54DE0102958cB9a8862FF219B6D37ff8BcF5CE33 ;

    function run() public returns (MigrateAaveV3OptimizerToBlue migrateAaveV3OptimizerToBlue) {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        migrateAaveV3OptimizerToBlue = new MigrateAaveV3OptimizerToBlue(morphoAddress);
        vm.stopBroadcast();
        return (migrateAaveV3OptimizerToBlue);
    }

   
    
    function getConfig() public pure returns (address, address, address) {
        return (aaveV3OptimizerAddress,  morphoAddress , migrateAaveV3OptimizerToBlueAddress);

    }
}
