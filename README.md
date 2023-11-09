# Space DAO consensus related smart contracts

This project gathers all the contracts involved in managing the consensus
mechanism, requests and thrustworthiness modeling and updates.

The [Hardat development environment](https://hardhat.org/) is used to build,
test and deploy this project. And more. 

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat run scripts/ConsensusS1/deploy.ts
```

## Setup

Before starting `credentials.json` should be created. Duplicate the `credentials.sample.json` file, rename it `credentials.json` and input the public and private key that the user is calling from. Do the same for `batch_authorise.json` with any public keys that you would like to immediately authorise when calling `scripts/quick_deploy.ts`.

## Useful Links

- [Default Public Keys for Hardhat](https://hardhat.org/hardhat-network/docs/reference#initial-state)