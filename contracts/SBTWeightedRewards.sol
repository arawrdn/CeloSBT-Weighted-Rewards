// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/ISBTReward.sol";

/**
 * @title SBTWeightedRewards
 * @dev Contract for distributing ERC20 rewards based on a user's SBT reputation level.
 * It queries the SBTReward contract from the CeloReputationDAO-Layer project.
 */
contract SBTWeightedRewards is Ownable {
    
    // Address of the SBT contract from the previous project
    address private immutable sbtRewardAddress;
    // Address of the token to be distributed as a reward (e.g., cUSD, community token)
    address private immutable rewardTokenAddress;

    // Reward weights map: SBT Tier ID => Weight Factor (e.g., 100 = 1x, 150 = 1.5x)
    mapping(uint256 => uint256) public rewardWeights; 

    // Event emitted when a reward is successfully claimed
    event RewardClaimed(address indexed recipient, uint256 baseAmount, uint256 finalAmount, uint256 sbtTier);

    constructor(address _sbtReward, address _rewardToken) {
        sbtRewardAddress = _sbtReward;
        rewardTokenAddress = _rewardToken;
        
        // Initial weights (can be updated by the owner/DAO later)
        rewardWeights[0] = 100; // Tier 0 (No SBT) = 1x
        rewardWeights[1] = 120; // Tier 1 = 1.2x
        rewardWeights[2] = 150; // Tier 2 = 1.5x
        rewardWeights[3] = 200; // Tier 3 = 2.0x
    }

    /**
     * @dev Sets the reward weight factor for a specific SBT tier.
     * @param _tierId The ID of the SBT Tier.
     * @param _newWeight The new weight factor (multiplied by 100).
     */
    function setRewardWeight(uint256 _tierId, uint256 _newWeight) external onlyOwner {
        require(_newWeight >= 100, "Weight must be 1x or higher");
        rewardWeights[_tierId] = _newWeight;
    }

    /**
     * @dev Calculates the final reward amount based on the user's SBT level.
     * @param _user The user's address.
     * @param _baseAmount The unweighted base reward amount.
     * @return finalAmount The final weighted amount.
     */
    function calculateWeightedReward(address _user, uint256 _baseAmount) public view returns (uint256) {
        ISBTReward sbt = ISBTReward(sbtRewardAddress);
        uint256 highestTier = sbt.getHighestSBTLevel(_user);
        
        uint256 weight = rewardWeights[highestTier];
        if (weight == 0) {
            weight = rewardWeights[0]; // Defaults to 1x if tier is not defined
        }

        // Final Amount = (Base Amount * Weight) / 100
        return (_baseAmount * weight) / 100;
    }

    /**
     * @dev Allows a user to claim their reward.
     * NOTE: A real implementation requires a mapping to track how much each user is eligible to claim.
     * @param _baseAmount The base reward amount the user is eligible for.
     */
    function claimReward(uint256 _baseAmount) external {
        // Assumption: An off-chain mechanism ensures the correct _baseAmount is used here.
        
        address recipient = msg.sender;
        uint256 finalAmount = calculateWeightedReward(recipient, _baseAmount);
        
        // 1. Perform token transfer
        bool success = IERC20(rewardTokenAddress).transfer(recipient, finalAmount);
        require(success, "SBTWeightedRewards: Token transfer failed");

        // 2. Log the claim (Actual claim tracking logic is omitted for simplicity)
        ISBTReward sbt = ISBTReward(sbtRewardAddress);
        emit RewardClaimed(recipient, _baseAmount, finalAmount, sbt.getHighestSBTLevel(recipient));
    }
}
