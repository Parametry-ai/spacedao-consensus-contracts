import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import { deploySpaceDAOIDContract, deployBaseConsensus, request_new_data_single, request_new_data_all} from "./functionals/test.functions";
//import { RequestAlreadySentError } from "web3";
import get_data from "./functionals/test.data"


describe("Submit Data BAD", async function () {


});