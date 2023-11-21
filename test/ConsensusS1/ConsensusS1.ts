// import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
// import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
// import { expect } from "chai";
// import { ethers } from "hardhat";

// describe("ConsensusS1", function () {
//   // We define a fixture to reuse the same setup in every test.
//   // We use loadFixture to run this setup once, snapshot that state,
//   // and reset Hardhat Network to that snapshot in every test.
//   async function deployBaseConsensus() {
//     // Contracts are deployed using the first signer/account by default
//     const [owner, otherAccount] = await ethers.getSigners();

//     const consensus_factory = await ethers.getContractFactory("ConsensusS1");
//     const consensus = await consensus_factory.deploy();

//     return { consensus, owner, otherAccount };
//   }

//   describe("Deployment", function () {
//     it("Should set the right owner", async function () {
//       const {consensus, owner } = await loadFixture(deployBaseConsensus);

//       expect(await consensus.owner).to.equal(owner.address);
//     });

//   });

//   describe("Events", function () {
//     it("Should emit an event on request", async function () {
//       const {consensus, owner} = await loadFixture(deployBaseConsensus);

//       await expect(consensus.request())
//         .to.emit(consensus, "CDMRequest_event")
//         .withArgs(anyValue);
//     });
//   });
// });
