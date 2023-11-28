// Function that calls add_notification function in smart contract

const hre = require("hardhat");
const path = require("path");
const { Signer, Wallet } = require("ethers");
const dapp_data = require("../../dapp/dapp-data.json");

// CHANGE auto FOR required account
const creds = config.networks.auto.accounts

// Converts private key to a signer
async function key_to_signer(priv) {
    const provider = hre.ethers.provider;
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
  }

async function main() {  
    // Gets smart contract ABI
    const Contract = await ethers.getContractFactory(dapp_data.contractName);
    // Attatches contract address for IRL location
    const dapp = await Contract.attach(dapp_data.dapp_address);

    tx_params = {
        gasLimit: 30000000  // Max gas per block on ethereum
    }

    // Template inputs (the addresses are default hardhat address')
    _suppliers_whitelist = [
        "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
        "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC",
        "0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    ]
    _tca_min = 3294
    _tca_max = 3298
    _rso_list = ["kjdnsaf", "idsnaflisad"]

    // Call function
    tx = await dapp.connect(await key_to_signer(creds[0])).newDataRequest(
        _suppliers_whitelist,
        _tca_min,
        _tca_max,
        _rso_list
    );
    console.log(tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});