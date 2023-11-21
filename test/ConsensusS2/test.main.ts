import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import {deployBaseConsensus, request_new_data_single, request_new_data_all} from "./test.functions";
import { RequestAlreadySentError } from "web3";

describe("ConsensusS2", function () {

  describe("Deployment", async function () {
    it("Should deploy all contracts", async function () {
      const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
      // Make sure an app is at each var
      expect(app_UserInfo, "UserInfo app did not build").to.not.equal(null);
      expect(app_Reputation, "Reputation app did not build").to.not.equal(null);
      expect(app_Consensus, "Consensus app did not build").to.not.equal(null);
      // console.log(KeySigner.address);
    });
    it("Should make sure cross app communication is set up", async function () {
      const { app_Consensus, app_UserInfo, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
      // Make sure app address link together across apps
      expect(await app_Consensus.userInfoApp(), "UserInfo app does not line up with that stored on Consensus app").to.equal(app_UserInfo.address)
      expect(await app_Consensus.reputationApp(), "Reputation app does not line up with that stored on Consensus app").to.equal(app_Reputation.address)
    });
    // WIP --- Tetsts for UserInfo deployment
    // WIP --- Tests for Reputation deployment
  });

  describe("New Data Request", async function () {
    it("Should call request new data function", async function () {
      const { app_Consensus, app_UserInfo, app_Reputation, tx_list } = await loadFixture(request_new_data_all);

      app_Consensus

      //console.log(tx_list);
      // await expect(await request_new_data(app_Consensus, caller, input_data, tx_params))
      //   .to.emit(app_Consensus, "NewCDMRequest");
      
    });
  });

});
