import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import { deploySpaceDAOIDContract, deployBaseConsensus, request_new_data_single, request_new_data_all} from "./functionals/test.functions";
//import { RequestAlreadySentError } from "web3";
import get_data from "./functionals/test.data"


describe("Data Request", async function () {
it("Should call request new data function once and emit event", async function () {
    await loadFixture(request_new_data_single);      
    // const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_all);      
});
it("Should call request new data function multiple times and emit event", async function () {
    await loadFixture(request_new_data_all);      
    // const { app_Consensus, app_UserInfo, app_Reputation } = await loadFixture(request_new_data_all);      
});
// WIP --- Test bad inputs
});