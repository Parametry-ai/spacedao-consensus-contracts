import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import { deploySpaceDAOIDContract, deployBaseConsensus, request_new_data_single, request_new_data_all} from "./functionals/test.functions";
//import { RequestAlreadySentError } from "web3";
import get_data from "./functionals/test.data"


describe("Deployment", async function () {
    it("Should deploy SpaceDAOID contract only", async function () {
        // console.log("DEBUG Deplying spaceDAOID contract");
        const {app_SpaceDAOID, KeySigner} = await loadFixture(deploySpaceDAOIDContract);
        expect(app_SpaceDAOID, "SpaceDAOID app did not build").to.not.equal(null);
        // console.log("DEBUG Deplying spaceDAOID contracti --- done.");
    });

    it("Should deploy all contracts", async function () {
        const { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
        // Make sure an app is at each var
        expect(app_SpaceDAOID, "UserInfo app did not build").to.not.equal(null);
        expect(app_Reputation, "Reputation app did not build").to.not.equal(null);
        expect(app_Consensus, "Consensus app did not build").to.not.equal(null);
    //  console.log(keySigner.address);
    });
    it("Should make sure cross app communication is set up", async function () {
        const { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner } = await loadFixture(deployBaseConsensus);
        // Make sure app address link together across apps
        expect(await app_Consensus.id_app(), "UserInfo app does not line up with that stored on Consensus app").to.equal(app_SpaceDAOID.address)
        // expect(await app_Consensus.reputationApp(), "Reputation app does not line up with that stored on Consensus app").to.equal(app_Reputation.address)
    });
    // WIP --- Tests for UserInfo deployment
    // WIP --- Tests for Reputation deployment
});
