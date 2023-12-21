import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import { deploySpaceDAOIDContract, deployBaseConsensus, request_new_data_single, request_new_data_all} from "./functionals/test.functions";
//import { RequestAlreadySentError } from "web3";
import get_data from "./functionals/test.data"

describe("Submit Data GOOD", async function () {
  it("Should allow for whitelisted users to submit data and emit event", async function () {
    const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_single);
    let data = get_data("new_cdm_submit")[0];
    let tx = await app_Consensus.connect(await data.caller)
      .submit(
          data.input_data[0], data.input_data[1], 
          data.input_data[2], data.input_data[3], 
          data.tx_params
      );
    await expect(tx).to.emit(
      app_Consensus, "DataSubmission"
    );
    let receipt = await tx.wait();
    let event_args = receipt.events[0].args;
    expect(event_args.provider).to.equal(data.caller_pub);
    expect(event_args.requestor).to.equal(data.input_data[0]);
    expect(event_args.nonce).to.equal(data.input_data[1]);
  });
  // it("Should allow for anyone to submit data and emit event", async function () {
  //   const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_single);
  //   let data = get_data("new_cdm_submit")[0]
  //   let tx = await app_Consensus.connect(await data.caller)
  //     .submit(
  //         data.input_data[0], data.input_data[1], 
  //         data.input_data[2], data.input_data[3], 
  //         data.tx_params
  //     )
  //   await expect(tx).to.emit(
  //     app_Consensus, "NewCDM"
  //   )
  //   let receipt = await tx.wait();
  //   let event_args = receipt.events[0].args[0]
  //   expect(event_args.pc).to.equal(data.input_data[2]);
  //   expect(event_args.tca).to.equal(data.input_data[3]);
  //   expect(event_args.supplier).to.equal(data.caller_pub);
  //   // Checks timestamp is between -100s and +100s from now
  //   expect(Number(event_args.unix_secs)).to.be.greaterThan(await time.latest()-100);
  //   expect(Number(event_args.unix_secs)).to.be.lessThan(await time.latest()+100);
  // });
  // it("Should complete when whitelists have all submitted data", async function () {
  //   const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_single);
  //   for (let i = 0; i < (get_data("new_cdm_submit")).length; i++ ) {
  //     let data = get_data("new_cdm_submit")[i]
  //     let tx = await app_Consensus.connect(await data.caller)
  //     .submit(
  //         data.input_data[0], data.input_data[1], 
  //         data.input_data[2], data.input_data[3], 
  //         data.tx_params
  //     )
  //     if (i == (get_data("new_cdm_submit")).length-1) {
  //       await expect(tx).to.emit(
  //         app_Consensus, "NewConsensusResult"
  //       )
  //     } else {
  //       await expect(tx).not.to.emit(
  //         app_Consensus, "NewConsensusResult"
  //       )
  //     }
  //   }
  // });
  // it("Should complete if timer runs out", async function () {
  //   const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_single);
  //   let data = get_data("new_cdm_submit")[0]
  //   let tx = await app_Consensus.connect(await data.caller)
  //   .submit(
  //       data.input_data[0], data.input_data[1], 
  //       data.input_data[2], data.input_data[3], 
  //       data.tx_params
  //   )
  //   await expect(tx).not.to.emit(
  //     app_Consensus, "NewConsensusResult"
  //   )
  //   // Skip time
  //   await time.increase(1100);
  //   // Submit new cdm after time passed
  //   data = get_data("new_cdm_submit")[1]
  //   tx = await app_Consensus.connect(await data.caller)
  //   .submitData(
  //       data.input_data[0], data.input_data[1], 
  //       data.input_data[2], data.input_data[3], 
  //       data.tx_params
  //   )
  //   await expect(tx).to.emit(
  //     app_Consensus, "NewConsensusResult"
  //   )
  // });
  // WIP --- Test bad inputs
});
