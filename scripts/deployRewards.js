// scripts/deployRewards.js
const hre = require("hardhat");
require("dotenv").config({ path: '../.env' }); 

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying rewards contract with the account:", deployer.address);

  // Fetch addresses from .env (the existing contracts)
  const sbtRewardAddress = process.env.SBT_REWARD_ADDRESS;
  const rewardTokenAddress = process.env.REWARD_TOKEN_ADDRESS; 

  if (!sbtRewardAddress || !rewardTokenAddress) {
    console.error("Missing SBT or Reward Token addresses in .env file.");
    return;
  }
  
  // Get the SBTWeightedRewards Contract Factory
  const SBTWeightedRewards = await hre.ethers.getContractFactory("SBTWeightedRewards");
  
  // Deploy the contract, passing the address of the old SBT contract and the reward token
  const rewardsContract = await SBTWeightedRewards.deploy(sbtRewardAddress, rewardTokenAddress);
  
  await rewardsContract.waitForDeployment();

  console.log("SBTWeightedRewards deployed to:", rewardsContract.target);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
