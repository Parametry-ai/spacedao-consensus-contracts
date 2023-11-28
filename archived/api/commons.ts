// SPDX-License-Identifier: LGPL-3.0-or-later

// Notice: Builds dapps
// Date: Nov-23
// Author: Robert Cowlishaw @0x365
// Dev: Needs commenting

import hre from "hardhat";
import { Wallet, BaseContract } from "ethers";

// User defined data
import config from "./config.json";

async function get_dapps (dapp_name: string, private_key: string) {
    // Builds dapps
    let signer = await key_to_signer(private_key)
    var address_0;
    var abi_0;
    var address;
    var abi;
    address_0 = (await import(config.path.Consensus)).dapp_address
    abi_0 = (await import(config.path.Consensus)).abi
    let app_Consensus = new BaseContract(address_0, abi_0).connect(signer);
    if (dapp_name == "Consensus") {
        // If consensus input just return consensus
        return app_Consensus 
    } else if (dapp_name == "UserInfo") {
        address = (await app_Consensus.connect(signer).userInfoApp()).toString();
        abi = (await import(config.path.UserInfo)).abi;
        return (new BaseContract(address, abi)).connect(signer);
    } else if (dapp_name == "Reputation") {
        address = (await app_Consensus.connect(signer).userInfoApp()).toString();
        abi = (await import(config.path.Reputation)).abi;
        return (new BaseContract(address, abi)).connect(signer);
    } else {
        console.log("Dapp Name not implemented (Go to commons.ts)")
        return (new BaseContract("null", "null")).connect(signer);
    }
}

async function key_to_signer(priv: string) {
    // Converts private key to a signer
    const provider = hre.ethers.provider;
    const signer_wallet = new Wallet(priv);
    const signer = signer_wallet.connect(provider);
    return signer;
}

export=get_dapps;