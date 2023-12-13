require('hardhat-gas-reporter');
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import creds from './credentials.json';
import nets from './networks_list.json';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: 'localhost',
  networks: {
    localhost: {
      url: nets.localhost,
      accounts: [creds.private_key],
      gas: 50000000,
      blockGasLimit: 50000000,
      chainId: 31337,
    },
    exochain_devnet: {
      url: nets.exochain,
      accounts: [creds.private_key],
    },
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
  gasReporter: {
    currency: 'EUR',
    gasPrice: 21,
  },
};

console.log('# Hardhat config loaded');
export default config;
