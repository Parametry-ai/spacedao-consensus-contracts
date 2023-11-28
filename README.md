# Space DAO consensus related smart contracts

This project gathers all the contracts involved in managing the consensus
mechanism, requests and thrustworthiness modeling and updates.

The [Hardat development environment](https://hardhat.org/) is used to build,
test and deploy this project. And more. 

## Quick Commands

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
# npx hardhat run scripts/ConsensusS1/deploy.ts
```

## Setup

Before starting `credentials.json` should be created. Duplicate the `credentials.sample.json` file, rename it `credentials.json` and input the public and private key that the user is calling from. 


## About

### Overview
A general overview of the current idea for architecture is given in the image below. The directory is split into `./contracts` for solidity smart contracts, `./scripts` for typescript scripts to call smart contracts, `./tests` for typescript tests to test the smart contracts and `./archived` for reference data and other code.

![Contract Architecture Figure](./docs/spacedao_stm_architecture.svg "Current architecture")

### Glossary

    - CDM: conjunction data message (all information about two space object
      dangerously getting closer)
    - TCA: time of closest approach (when are these objects crossing each other)
    - PC: probability of collision (it is used like an emergency score in the end)
    - RSO: resident space object (technical word to name anything in space, from
      active satellites to debris to asteroids)

## Dev

Do the same for `batch_authorise.json` with any public keys that you would like to immediately authorise when calling `scripts/quick_deploy.ts`.

### Useful Links

- [Default Public Keys for Hardhat](https://hardhat.org/hardhat-network/docs/reference#initial-state). They are also listed with the private keys in `./test/default_hardhat_key.json`.
