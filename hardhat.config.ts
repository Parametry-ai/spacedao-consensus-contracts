import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import creds from "./credentials.json";
import nets from "./networks_list.json";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  defaultNetwork: "auto",
  networks: {
    auto: {
      url: nets.def,
      accounts: [creds.private_key]
    },
    localhost: {
      url: nets.localhost,
      accounts: [creds.private_key]
    },
    exochain_devnet: {
      url: nets.exochain,
      accounts: [creds.private_key]
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

console.log("# Hardhat config loaded");
export default config;
