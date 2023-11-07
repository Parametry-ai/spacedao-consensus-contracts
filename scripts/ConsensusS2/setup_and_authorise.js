// Function that deploy smart contract ConsensusS2.sol

const hre = require("hardhat");
const path = require("path");
const { Signer, Wallet } = require("ethers");

// Converts private key to a signer
async function key_to_signer(priv) {
    const provider = hre.ethers.provider;
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
}

// CHANGE auto FOR required account
const creds = config.networks.auto.accounts

async function deployContract(contract_title, args=[]) {
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
    // console.log(await dapp.wait());
    return dapp.address;
}

async function main() {
    // Saves deployed smart contract details to artifacts folders
    // --- Change this to save all dapps data
    // save_artifacts(dapp, tx.deployTransaction.chainId);

    const user_info_contract_name = "UserInfo";
    const user_info_address = await deployContract(user_info_contract_name, ["rob"]);
    const user_info_abi = await ethers.getContractFactory(user_info_contract_name);
    const user_info_dapp = user_info_abi.attach(user_info_address);

    const reputation_contract_name = "Reputation";
    const reputation_address = await deployContract(reputation_contract_name);
    const reputation_abi = await ethers.getContractFactory(reputation_contract_name);
    const reputation_dapp = reputation_abi.attach(reputation_address);

    const consesus_contract_name = "ConsensusS2";
    const consensus_address = await deployContract(consesus_contract_name, [user_info_address, reputation_address]);
    const consensus_abi = await ethers.getContractFactory(consesus_contract_name);
    const consensus_dapp = consensus_abi.attach(consensus_address);

    
}

// function jsonConcat(o1, o2) {
//     for (var key in o2) {
//         o1[key] = o2[key];
//     }
//     return o1;
// }

// // Save deployed smart contract details to artifacts folders
// function save_artifacts(dapp, chainId) {
//     const fs = require("fs");

//     const dapp_artifact = artifacts.readArtifactSync(contract_name);

//     var output_artifacts = {};
//     output_artifacts = jsonConcat({ dapp_address: dapp.address }, dapp_artifact);
//     output_artifacts = jsonConcat({ network_chain_id: chainId }, output_artifacts);

//     // Create contract artifacts for general use
//     const dir_general_artifacts = path.join(__dirname, "..", "..", "dapp");
//     if (!fs.existsSync(dir_general_artifacts)) {
//         fs.mkdirSync(dir_general_artifacts);
//     }
//     fs.writeFileSync(
//         path.join(dir_general_artifacts, "dapp-data.json"),
//         JSON.stringify(output_artifacts, undefined, 2)
//     );
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});