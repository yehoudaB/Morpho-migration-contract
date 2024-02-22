# Migrate Your Morpho Optimizer positions to Morpho Blue


### testing
```
    forge test --fork-url $ETHEREUM_RPC_URL -vvvv --mt testFunctionName
````

### Deploying on TENDERLY fork 
```
    forge script script/DeployMigrateToBlue.s.sol:DeployMigrateToBlue  --rpc-url $TENDERLY_RPC_URL  --broadcast
````


forge verify-contract --chain-id 1 --watch --verifier etherscan 0x45c87d488edB3Abc25C1BA8F165b5581987735AA  MigrateAaveV3OptimizerToBlue   --constructor-args $(cast abi-encode "constructor(address,address)" 0x2f39d218133AFaB8F2B819B1066c7E434Ad94E9e 0x823Be23F5a90bb629D30Bb0ecc8777b4c15b6F17) 