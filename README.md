# Space DAO consensus related smart contracts

This project gathers all the small programs (smart-contracts) involved in
managing the consensus mechanism for space traffic exchange of Conjunction Data
Messages (CDMs), requests and thrustworthiness modeling and updates.

[Visit the Space DAO dashboard to see current network activity (COMING SOON)](https://spacedao.ai)


Here is a glossary of most important terms and acronyms:
- **CCSDS**: [The Consultative Committee for Space Data Systems](https://ccsds.org)
- **CDM**: conjunction data message, see [CCSDS Recomended Standard Blue Book](https://public.ccsds.org/Pubs/508x0b1e2c2.pdf).
  CDMs represent all information about conjunction between two space object dangerously getting closer.
- **TCA**: time of closest approach (when are these objects crossing each other)
- **PC** or Pc: probability of collision (it is used like an emergency score in the end)
- **RSO**: resident space object (technical word to name anything in space, from
  active satellites to debris to asteroids)
- **space operators**: part of the network users, space operators mainly benefit
  from CDMs built from consensus so their decision to maneuvers can be made in
  more confidence, and eventually less often.
- **SSA providers**: they are space monitoring services, group or companies,
  that respond to network requests for CDMs. Each CDM from providers are sent
  back to the consensus contract, upon each request.
- **smart contract**: fancy technical term  to name "small online distributed
  programs". They are as smart as we make them and they are legally no contract
  until we would bind them with real world signatures. So consider these as
  online services you could interact with with account information you are
  solely own.
- **third party stakeholders**: we are preparing room for interactions with
  other stakeholders like space lawyers and insurers to have an incentivized
  effect on the business mechanics of the network.

[Visit the Space DAO dashboard to see current network activity (COMING SOON)](https://spacedao.ai)

## For developers 

We use the [Hardat development environment](https://hardhat.org/) to build, test
and deploy this project. 

### Quick recap of commands

```shell
npm install
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
# npx hardhat run scripts/ConsensusS1/deploy.ts
# npx hardhat run scripts/ConsensusS2/deploy.ts
```

### Setup

#### Credentials

Before starting `credentials.json` should be created. Duplicate the
`credentials.sample.json` file, rename it `credentials.json` and input the
public and private key that the user is calling from. So deployment and other
actions can sign transactions.

`credentials.json` is in .gitignore to avoid being it shared.
Please nevertheless use a test private key.

#### Whitelist authorisations

Do the same for `batch_authorise.json` with any public keys that you would like
to immediately authorise when calling `scripts/quick_deploy.ts`.


### Overview

A general overview of the current idea for architecture is given in the image below. The directory is split into `./contracts` for solidity smart contracts, `./scripts` for typescript scripts to call smart contracts, `./tests` for typescript tests to test the smart contracts and `./archived` for reference data and other code.

![Contract Architecture Figure](./docs/spacedao_stm_architecture.svg "Current architecture")


### Useful Links

- [Default Public Keys for Hardhat](https://hardhat.org/hardhat-network/docs/reference#initial-state). They are also listed with the private keys in `./test/default_hardhat_key.json`.
