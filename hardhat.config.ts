import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import creds from "./credentials.json";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    exochain_devnet: {
      url: "https://exochain.dev.parametry.space/",
      accounts: [creds.private_key]
    }
  }
};

console.log("config loaded");
console.log(creds);
export default config;
