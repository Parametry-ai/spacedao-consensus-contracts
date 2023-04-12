import { ethers } from "hardhat";

async function main() {
  const currentTimestampInSeconds = Math.round(Date.now() / 1000);

  const consensus_factory = await ethers.getContractFactory("ConsensusS1");
  const consensus_a = await consensus_factory.deploy();

  await consensus_a.deployed();

  console.log(
    `Consensus S1 contract deployed around ${currentTimestampInSeconds} deployed to ${consensus_a.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
