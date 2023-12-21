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

import default_keys from '../default_hardhat_keys.json';
import key_to_signer from './test.key_converter';
import get_data from './test.data';

chai.use(solidity);

async function deploySpaceDAOIDContract() {
  const KeySigner = await key_to_signer(
    default_keys.private_key_list[0]
  );
  var appSpaceDAOID = await deployContract(
    'SpaceDAOID',
    KeySigner,
    ['Leon Ladmin']);
  return { appSpaceDAOID, KeySigner };
}

async function deployBaseConsensus() {
  // The id of the address in default_hardhat_keys.json
  let i = 0;
  // Contracts are deployed using the first signer/account by default
  const KeySigner = await key_to_signer(
    default_keys.private_key_list[i]
  );
  var app_Consensus = null;
  var app_UserInfo = null;
  var app_Reputation = null;
  // Main function to call deploy contracts for each required contract
  let name_ = 'firstStarterName';
  // Deploys UserInfo Contract
  const user_info_contract_name = 'SpaceDAOID';
  app_UserInfo = await deployContract(
    user_info_contract_name,
    KeySigner,
    [
      name_
    ]
  );
  // string memory _adminOwner_name, string[] memory _admin_names, address[] memory _admin_addresses
  if (app_UserInfo == null) {
    return { app_Consensus, app_UserInfo, app_Reputation, KeySigner };
  }
  // Deploys Reputation Contract
  const reputation_contract_name = 'Reputation';
  app_Reputation = await deployContract(
    reputation_contract_name,
    KeySigner
  );
  if (app_Reputation == null) {
    return { app_Consensus, app_UserInfo, app_Reputation, KeySigner };
  }
  // Deploys ConsensusS2 Contract
  const consensus_contract_name = 'ConsensusS2';
  app_Consensus = await deployContract(
    consensus_contract_name,
    KeySigner,
    [app_UserInfo.address]
  );
  // Returns
  return { app_Consensus, app_UserInfo, app_Reputation, KeySigner };
}

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
    // console.log('here1');
    // console.log(args);
    // console.log(KeySigner);
    dapp = await Contract.connect(KeySigner).deploy(
      args[0],
      args[1],
      args[2]
    );
    // console.log('here2');
  } else {
    return null;
  }
  // console.log('IT HAS DEPLOYED');
  const tx = await dapp.deployed();
  // console.log('IT HAS DEPLOYED SUCCESS');
  return dapp;
}

// async function request_new_data_single() {
//     // Sends single data request to consensus app
//     let tx_list = [];
//     let data = get_data("new_data_requests_list")[0]
//     const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
//     let tx = await app_Consensus.connect(await data.caller)
//         .requestData(data.input_data[0], data.input_data[1],
//                         data.input_data[2], data.input_data[3],
//                         data.tx_params)
//     tx.data = "data..."
//     tx_list.push(tx)
//     return { app_Consensus, app_UserInfo, app_Reputation, tx_list }
// };

async function request_new_data_single() {
  // Sends all data request to consensus app
  const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } =
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
  // for (let j = 0; j < data.input_data[0].length; j++) {
  //   expect(event_args.suppliers_whitelist[j]).to.equal(
  //     data.input_data[0][j]
  //   );
  // }
  // expect(Number(event_args.request_time_max)).to.equal(1000); // WIP -- Change to vary with pub var on contract
  // expect(Number(event_args.tca_min)).to.equal(data.input_data[1]);
  // expect(Number(event_args.tca_max)).to.equal(data.input_data[2]);
  // for (let j = 0; j < data.input_data[3].length; j++) {
  //   expect(event_args.rso_list[j]).to.equal(data.input_data[3][j]);
  // }
  // // Checks timestamp is between -100s and +100s from now
  // expect(Number(event_args.request_time)).to.be.greaterThan(
  //   (await time.latest()) - 100
  // );
  // expect(Number(event_args.request_time)).to.be.lessThan(
  //   (await time.latest()) + 100
  // );
  return { app_Consensus, app_UserInfo, app_Reputation };
}

async function request_new_data_all() {
  // Sends all data request to consensus app
  const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } =
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
    // for (let j = 0; j < data.input_data[0].length; j++) {
    //   expect(event_args.suppliers_whitelist[j]).to.equal(
    //     data.input_data[0][j]
    //   );
    // }
    // expect(Number(event_args.request_time_max)).to.equal(1000); // WIP -- Change to vary with pub var on contract
    // expect(Number(event_args.tca_min)).to.equal(data.input_data[1]);
    // expect(Number(event_args.tca_max)).to.equal(data.input_data[2]);
    // for (let j = 0; j < data.input_data[3].length; j++) {
    //   expect(event_args.rso_list[j]).to.equal(data.input_data[3][j]);
    // }
    // // Checks timestamp is between -100s and +100s from now
    // expect(Number(event_args.request_time)).to.be.greaterThan(
    //   (await time.latest()) - 100
    // );
    // expect(Number(event_args.request_time)).to.be.lessThan(
    //   (await time.latest()) + 100
    // );
  }
  return { app_Consensus, app_UserInfo, app_Reputation };
}

export {
  deploySpaceDAOIDContract,
  deployBaseConsensus,
  request_new_data_single,
  request_new_data_all,
};
