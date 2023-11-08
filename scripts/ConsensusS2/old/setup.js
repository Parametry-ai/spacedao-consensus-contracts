// SPDX-License-Identifier: LGPL-3.0-or-later

// Notice: Function that deploys smart contract ConsensusS2.sol
// Date: Nov-23
// Author: Robert Cowlishaw @0x365

const hre = require("hardhat");
const path = require("path");
const { Wallet } = require("ethers");
const fs = require("fs");

// Change auto for required account
const creds = config.networks.auto.accounts

async function main() {
    // Main function to call deploy contracts for each required contract
    let name_ = "firstStarterName"
    // Deploys UserInfo Contract
    const user_info_contract_name = "UserInfo";
    const user_info_address = await deployContract(user_info_contract_name, [name_]);
    const user_info_abi = await ethers.getContractFactory(user_info_contract_name);
    const user_info_dapp = user_info_abi.attach(user_info_address);
    console.log(user_info_contract_name, "Contract Deployed")
    // Deploys Reputation Contract
    const reputation_contract_name = "Reputation";
    const reputation_address = await deployContract(reputation_contract_name);
    const reputation_abi = await ethers.getContractFactory(reputation_contract_name);
    const reputation_dapp = reputation_abi.attach(reputation_address);
    console.log(reputation_contract_name, "Contract Deployed")
    // Deploys ConsensusS2 Contract
    const consensus_contract_name = "ConsensusS2";
    const consensus_address = await deployContract(consensus_contract_name, [user_info_address, reputation_address]);
    const consensus_abi = await ethers.getContractFactory(consensus_contract_name);
    const consensus_dapp = consensus_abi.attach(consensus_address);
    console.log(consensus_contract_name, "Contract Deployed")
    console.log("COMPLETED - All Contracts Deployed")
}

main().catch((error) => {
    // We recommend this pattern to be able to use async/await everywhere
    // and properly handle errors
    console.error(error);
    process.exitCode = 1;
});

async function key_to_signer(priv) {
    // Converts private key to a signer
    const provider = hre.ethers.provider;
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
}

async function deployContract(contract_title, args = []) {
    // Deploys contract with input title and saves artifacts
    // Dev - Only allows between 0 and 3 arguments
    const Contract = await hre.ethers.getContractFactory(contract_title);
    tx_params = {
        gasLimit: 30000000
    };
    if (args.length == 0) {
        var dapp = await Contract.connect(await key_to_signer(creds[0])).deploy(tx_params);
    } else if (args.length == 1) {
        var dapp = await Contract.connect(await key_to_signer(creds[0])).deploy(args[0], tx_params)
    } else if (args.length == 2) {
        var dapp = await Contract.connect(await key_to_signer(creds[0])).deploy(args[0], args[1], tx_params)
    } else if (args.length == 3) {
        var dapp = await Contract.connect(await key_to_signer(creds[0])).deploy(args[0], args[1], args[2], tx_params)
    }
    const tx = await dapp.deployed();
    save_artifacts(contract_title, dapp, tx.deployTransaction.chainId);
    return dapp.address;
}

function jsonConcat(o1, o2) {
    // Combines two json elements into one
    for (var key in o2) {
        o1[key] = o2[key];
    }
    return o1;
}

function save_artifacts(contract_name, dapp, chainId) {
    // Save deployed smart contract artifacts to dapp folder
    // Gets artifacts from contract
    const dapp_artifact = artifacts.readArtifactSync(contract_name);
    // Adds app address and chainId that its deployed on
    var output_artifacts = {};
    output_artifacts = jsonConcat({ dapp_address: dapp.address }, dapp_artifact);
    output_artifacts = jsonConcat({ network_chain_id: chainId }, output_artifacts);
    // Try and create dapp directory if it doesnt already exist
    const dir_general_artifacts = path.join(__dirname, "..", "..", "dapp");
    if (!fs.existsSync(dir_general_artifacts)) {
        fs.mkdirSync(dir_general_artifacts);
    }
    // Overwrite dapp data json file or create if doesnt exist
    fs.writeFileSync(
        path.join(dir_general_artifacts, "dapp_" + contract_name +".json"),
        JSON.stringify(output_artifacts, undefined, 2)
    );
}

