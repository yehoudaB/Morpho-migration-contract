# Migrate Your Morpho Optimizer positions to Morpho Blue


### testing
```
    forge test --fork-url $ETHEREUM_RPC_URL -vvvv --mt testFunctionName
````

### Deploying on TENDERLY fork 
```
    forge script script/DeployMigrateToBlue.s.sol:DeployMigrateToBlue  --rpc-url $TENDERLY_RPC_URL  --broadcast
````