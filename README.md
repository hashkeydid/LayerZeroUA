# How to deploy DidSync Contract

1. Deploying proxy contract and logic contract first, and initialize it.

```shell
npx hardhat deploy --network goerli --tags DidSync
npx hardhat deploy --network goerli --tags EXTERNAL_STORAGE
npx hardhat --network goerli initProxy --did [didAddrs]
```

2. To enable sync DID functionality, run below:

```shell
npx hardhat --network [from chain] setTrustedRemote --target-network [to chain]
```