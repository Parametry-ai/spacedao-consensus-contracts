import {
  time,
  loadFixture,
} from '@nomicfoundation/hardhat-network-helpers';
//import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from 'chai';
import { ethers } from 'hardhat';
//import { Wallet } from "ethers";

import chai from 'chai';
import { solidity } from 'ethereum-waffle';

import default_keys from '../../default_hardhat_keys.json';
import key_to_signer from './test.key_converter';
import get_data from './test.data';

chai.use(solidity);


// Deploys any contract with 0 to 3 input args
async function deployContract(
  contract_title: string,
  KeySigner: any,
  args?: any
) {
  // Deploys contract with input title
  // Dev - Only allows between 0 and 3 arguments
  const Contract = await ethers.getContractFactory(contract_title);
  // Deploys with correct number of input arguments
  var dapp;
  if (args == null) {
    dapp = await Contract.connect(KeySigner).deploy();
  } else if (args.length == 1) {
    dapp = await Contract.connect(KeySigner).deploy(args[0]);
  } else if (args.length == 2) {
    dapp = await Contract.connect(KeySigner).deploy(args[0], args[1]);
  } else if (args.length == 3) {
    dapp = await Contract.connect(KeySigner).deploy(args[0], args[1], args[2]);
  } else {
    return null;
  }
  const tx = await dapp.deployed();
  return dapp;
}


// Deploys SpaceDAOID Contract Only
async function deploySpaceDAOIDContract() {
  // Contracts are deployed using the first signer/account by default
  let i = 0;
  const KeySigner = await key_to_signer(
    default_keys.private_key_list[i]
  );

  // Deploys SpaceDAOID Contract
  const app_SpaceDAOID_contract_name = 'SpaceDAOID';
  var app_SpaceDAOID;
  app_SpaceDAOID = await deployContract(
    app_SpaceDAOID_contract_name,
    KeySigner,
    ['firstStarterName']
  );
  expect(app_SpaceDAOID).to.not.equal(null)
  return { app_SpaceDAOID, KeySigner };
}


// Deploys all contracts for Consensus
async function deployBaseConsensus() {
  // Contracts are deployed using the first signer/account by default
  let i = 0;
  const KeySigner = await key_to_signer(
    default_keys.private_key_list[i]
  );

  // Deploys SpaceDAOID Contract
  const app_SpaceDAOID_contract_name = 'SpaceDAOID';
  var app_SpaceDAOID;
  app_SpaceDAOID = await deployContract(
    app_SpaceDAOID_contract_name,
    KeySigner,
    ['firstStarterName']
  );
  expect(app_SpaceDAOID).to.not.equal(null)

  // Deploys Reputation Contract
  const reputation_contract_name = 'Reputation';
  var app_Reputation;
  app_Reputation = await deployContract(
    reputation_contract_name,
    KeySigner
  );
  expect(app_Reputation).to.not.equal(null)

  // Deploys ConsensusCDM Contract
  const consensus_contract_name = 'ConsensusCDM';
  var app_Consensus;
  app_Consensus = await deployContract(
    consensus_contract_name,
    KeySigner,
    [app_SpaceDAOID.address]
  );
  expect(app_Consensus).to.not.equal(null)

  // Returns
  return { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner };
}


// Test first data input to request function in Consensus
async function request_new_data_single() {
  // Sends all data request to consensus app
  const { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner } =
    await loadFixture(deployBaseConsensus);
  let data = get_data('new_data_requests_list')[0];
  if (app_Consensus == null) {
    return null;
  }
  let tx = await app_Consensus
    .connect(await data.caller)
    .requestData(
      data.input_data[0],
      data.input_data[1],
      data.input_data[2],
      data.input_data[3],
      data.tx_params
    );
  await expect(tx).to.emit(app_Consensus, 'newRequest');
  let receipt = await tx.wait();
  let event_args = receipt.events[0].args[0];

  // Checks all parameters of request
  expect(event_args).to.equal(data.caller_pub);

  return { app_Consensus, app_SpaceDAOID, app_Reputation };
}


// Test all data inputs to request function in Consensus
async function request_new_data_all() {
  // Sends all data request to consensus app
  const { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner } =
    await loadFixture(deployBaseConsensus);
  for (
    let i = 0;
    i < get_data('new_data_requests_list').length;
    i++
  ) {
    let data = get_data('new_data_requests_list')[i];
    if (app_Consensus == null) {
      return null;
    }
    let tx = await app_Consensus
      .connect(await data.caller)
      .requestData(
        data.input_data[0],
        data.input_data[1],
        data.input_data[2],
        data.input_data[3],
        data.tx_params
      );
    await expect(tx).to.emit(app_Consensus, 'newRequest');
    let receipt = await tx.wait();
    let event_args = receipt.events[0].args[0];

    // Checks all parameters of request
    expect(event_args).to.equal(data.caller_pub);

  }
  return { app_Consensus, app_SpaceDAOID, app_Reputation };
}


// Exports function (Add function to use in different script)
export {
  deploySpaceDAOIDContract,
  deployBaseConsensus,
  request_new_data_single,
  request_new_data_all,
};
