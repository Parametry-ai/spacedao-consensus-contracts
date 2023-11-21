import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";

import chai from "chai";
import { solidity } from "ethereum-waffle";

import default_keys from "../default_hardhat_keys.json"
import key_to_signer from "./test.key_converter";
import get_data from "./test.data"

chai.use(solidity);

async function deployBaseConsensus() {
    // The id of the address in default_hardhat_keys.json
    let i = 0
    // Contracts are deployed using the first signer/account by default
    const KeySigner = await key_to_signer(default_keys.private_key_list[i]);
    var app_Consensus = null;
    var app_UserInfo = null;
    var app_Reputation = null;
    // Main function to call deploy contracts for each required contract
    let name_ = "firstStarterName";
    // Deploys UserInfo Contract
    const user_info_contract_name = "UserInfo";
    app_UserInfo = await deployContract(user_info_contract_name, KeySigner, [name_]);
    if (app_UserInfo == null) {
        return { app_Consensus, app_UserInfo, app_Reputation, KeySigner }
    }
    // Deploys Reputation Contract
    const reputation_contract_name = "Reputation";
    app_Reputation = await deployContract(reputation_contract_name, KeySigner);
    if (app_Reputation == null) {
        return { app_Consensus, app_UserInfo, app_Reputation, KeySigner }
    }
    // Deploys ConsensusS2 Contract
    const consensus_contract_name = "ConsensusS2";
    app_Consensus = await deployContract(consensus_contract_name, KeySigner, [app_UserInfo.address, app_Reputation.address]);
    // Returns
    return { app_Consensus, app_UserInfo, app_Reputation, KeySigner };
}

async function deployContract(contract_title: string, KeySigner: any, args?: any) {
    // Deploys contract with input title
    // Dev - Only allows between 0 and 3 arguments
    const Contract = await ethers.getContractFactory(contract_title);
    let tx_params = {
        gasLimit: 30000000
    };
    // Deploys with correct number of input arguments
    var dapp;
    if (args == null) {
        dapp = await Contract.connect(KeySigner).deploy(tx_params);
    } else if (args.length == 1) {
        dapp = await Contract.connect(KeySigner).deploy(args[0], tx_params);
    } else if (args.length == 2) {
        dapp = await Contract.connect(KeySigner).deploy(args[0], args[1], tx_params);
    } else if (args.length == 3) {
        dapp = await Contract.connect(KeySigner).deploy(args[0], args[1], args[2], tx_params);
    } else {
        return null;
    }
    const tx = await dapp.deployed();
    return dapp
}


async function request_new_data_single() {
    // Sends single data request to consensus app
    let tx_list = [];
    let data = get_data("new_data_requests_list")[0]
    const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
    let tx = await app_Consensus.connect(await data.caller)
        .newDataRequest(data.input_data[0], data.input_data[1], 
                        data.input_data[2], data.input_data[3], 
                        data.tx_params)
    tx.data = "data..."
    tx_list.push(tx)
    return { app_Consensus, app_UserInfo, app_Reputation, tx_list }
};

async function request_new_data_all() {
    // Sends all data request to consensus app
    const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
    for (let i = 0; i < get_data("new_data_requests_list").length; i++) {
        let data = get_data("new_data_requests_list")[i]
        await expect(await app_Consensus.connect(await data.caller)
            .newDataRequest(
                data.input_data[0], data.input_data[1], 
                data.input_data[2], data.input_data[3], 
                data.tx_params
            )
        )
        .to.emit(
            app_Consensus, "NewCDMRequest"
        )
        .withNamedArgs({new_request: anyValue});

        // READ THIS https://ethereum-waffle.readthedocs.io/en/latest/matchers.html

        // .withArgs(
        //     CDMRequest
        // );
        
        // let tx = await app_Consensus.connect(await data.caller)
        //     .newDataRequest(
        //         data.input_data[0], data.input_data[1], 
        //         data.input_data[2], data.input_data[3], 
        //         data.tx_params
        // )
        // let receipt = await tx.wait()
        // for (const event of receipt.events) {
        //     console.log(`Event ${event.event} with args ${event.args}`);
        // }
    };
    return { app_Consensus, app_UserInfo, app_Reputation }
};


// address requester;  // msg.sender
//         address issuer;     // msg.sender
//         address[3] suppliers_whitelist; // list of addresses TODO
//         uint request_time_max;  // ?
//         uint request_time;  // Time Now
//         uint tca_min;       // Time input
//         uint tca_max;       // Time input 2
//         string[2] rso_list; // Sat Data

export {deployBaseConsensus, request_new_data_single, request_new_data_all};
