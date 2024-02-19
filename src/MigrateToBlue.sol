// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IMorphoFlashLoanCallback} from "@morpho-blue/interfaces/IMorphoCallbacks.sol";
import {IMorpho} from "@morpho-blue/interfaces/IMorpho.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "forge-std/Console.sol";

contract MigrateAaveV3OptimizerToBlue  is IMorphoFlashLoanCallback {
    
    IMorpho private immutable MORPHO;

    constructor(IMorpho newMorpho) {
        MORPHO = newMorpho;
    }

    function flashLoan(address token, uint256 assets, bytes calldata data) external {
        MORPHO.flashLoan(token, assets, data);
    }

    function onMorphoFlashLoan(uint256 assets, bytes calldata data) external {
        require(msg.sender == address(MORPHO));
        address token = abi.decode(data, (address));
        IERC20(token).approve(address(MORPHO), assets);

        console.log("Flash loaned %s %s", IERC20(token).balanceOf(address(this)));
    }
}