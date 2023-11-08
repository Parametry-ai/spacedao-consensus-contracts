// SPDX-License-Identifier: LGPL-3.0-or-later

// Notice: Example function that creates a new user on UserInfo dapp
// Date: Nov-23
// Author: Robert Cowlishaw @0x365
// Dev: Will automatically overwrite name if it id already exists

const hre = require("hardhat");
const path = require("path");
const { Signer, Wallet } = require("ethers");

const {creds} = require("./credentials.json");
const {config} = require("./config.json");

// Converts private key to a signer
async function key_to_signer(priv) {
    const provider = hre.ethers.provider;
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
}


async function main() {

    let name_ = "TestName"

    tx_params = {
        gasLimit: 30000000
    };

    // Connect to Consensus App
    const consensus_contract_name = config.ContractVersion.Consensus;
    const consensus_address = config.AppAddress.Consensus
    const consensus_abi = await ethers.getContractFactory(consensus_contract_name);
    const consensus_dapp = consensus_abi.attach(consensus_address);

    // Connect to UserInfo App
    const user_info_contract_name = config.ContractVersion.UserInfo
    const user_info_address = consensus_dapp.userInfoApp().toString();  // Gets user_info_address from consensus app
    const user_info_abi = await ethers.getContractFactory(user_info_contract_name);
    const user_info_dapp = user_info_abi.attach(user_info_address);

    // Get id from UserInfo App
    my_id = await user_info_dapp.connect(await key_to_signer(creds.private_key)).whatIsMyID();
    console.log(my_id)

    // If id == 0 account does not exist
    if (my_id == 0) {
        console.log("Account doesnt exist. Creating new account....")
        tx = await user_info_dapp.connect(await key_to_signer(creds.private_key)).newUser(name_, tx_params);
        console.log(tx);
    // Else account already exists and id was returned
    } else {
        console.log("Account already exists at id=", my_id,". Changing name on account to _name")
        tx = await user_info_dapp.connect(await key_to_signer(creds.private_key)).changeName(name_, tx_params);
        console.log(tx);
    }

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});