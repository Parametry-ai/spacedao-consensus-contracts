import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Wallet } from "ethers";


import { deploySpaceDAOIDContract, deployBaseConsensus, request_new_data_single, request_new_data_all} from "./functionals/test.functions";
//import { RequestAlreadySentError } from "web3";
import get_data from "./functionals/test.data"

describe("Template Test", async function () {
    it("Should deploy contracts and be ready to test other things", async function () {
        // This line deploys contracts
        const { app_Consensus, app_SpaceDAOID, app_Reputation, KeySigner } =
            await loadFixture(deployBaseConsensus);

        // ASSERT - that apps all exist
        expect(app_Consensus).to.not.equal(null)
        expect(app_SpaceDAOID).to.not.equal(null)
        expect(app_Reputation).to.not.equal(null)

        // This line collects data from functionals/test.data.ts for the tests
        let data = get_data('new_data_requests_list')[0];

        // This line calls requestData function in app_Consensus
        let tx = await app_Consensus
            .connect(await data.caller) // This is msg.sender in contract
            .requestData(
            data.input_data[0],
            data.input_data[1],
            data.input_data[2],
            data.input_data[3],
            data.tx_params
            );

        // ASSERT - that event is emitted with specific name
        await expect(tx).to.emit(app_Consensus, 'newRequest');

        // This gets the data from transaction as asynchronus
        let receipt = await tx.wait();

        // This gives the arguments of the event emit
        let event_args = receipt.events[0].args;
        // console.log(event_args)
    });
});