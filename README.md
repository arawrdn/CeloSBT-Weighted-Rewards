# CeloSBT-Weighted-Rewards

## Introduction

**CeloSBT-Weighted-Rewards** is a decentralized application (DApp) on the Celo network designed to introduce dynamic, reputation-based rewards. It acts as a crucial incentive layer for the governance system established by the **CeloReputationDAO-Layer** project.

This contract ensures that reward distribution is not flat, but instead **weighted** by a user's verified reputation, as measured by the Soul-Bound Tokens (SBTs) they hold. This strengthens community participation, encourages long-term commitment, and rewards users who contribute most to the health and stability of the Celo ecosystem.

## 🔗 Project Interoperability

This contract is entirely dependent on the successful deployment and operation of the following contract from your previous project:

| Contract | Function | Address (Example) |
| :--- | :--- | :--- |
| **SBTReward.sol** | Provides the user's `highestSBTLevel` (reputation tier) for weighting calculation. | `0x5ba23E827e684F8171983461f1D0FC3b41bECbC3` |

## Core Mechanics

The reward mechanism operates in two primary steps:

### 1. Reputation Query
The `SBTWeightedRewards.sol` contract calls the external `SBTReward.sol` contract to determine the recipient's highest SBT tier (e.g., Tier 1, Tier 2, Tier 3).

### 2. Weighted Calculation and Distribution
The highest tier is mapped to a preset **Reward Weight Factor** ($R_w$). The final reward ($R_f$) is then calculated based on the base reward ($R_b$) the user is eligible for:

$$R_f = R_b \times \frac{R_w}{100}$$

| SBT Tier | Weight Factor ($R_w$) | Multiplier | Example Final Reward (if $R_b=100$) |
| :--- | :--- | :--- | :--- |
| 0 (No SBT) | 100 | 1x | 100 Tokens |
| 1 | 120 | 1.2x | 120 Tokens |
| 3 (Highest) | 200 | 2.0x | 200 Tokens |

This weighted transfer incentivizes users to earn higher SBT tiers, thus promoting the desired behaviors set by the original reputation engine.

## Contracts

| Contract File | Description | Status |
| :--- | :--- | :--- |
| `SBTWeightedRewards.sol` | Main logic for calculating and distributing rewards based on SBT weight. | **New Deployment** |
| `ISBTReward.sol` | Interface required to interact with the existing SBT contract. | Interface |

## Deployment and Setup

### Prerequisites

1.  Node.js and npm/yarn.
2.  Hardhat installed globally or locally.
3.  A Celo wallet funded with CELO/cUSD for gas fees.
4.  Your existing `SBTReward.sol` contract must be deployed on the target Celo network (Alfajores or Mainnet).

### 1. Configuration

Ensure your `.env` file is properly configured with your keys and contract addresses.

```env
MNEMONIC="..."
ALFAJORES_URL="..."

# Addresses from the previous CeloReputationDAO-Layer project
SBT_REWARD_ADDRESS="0x5ba23E827e684F8171983461f1D0FC3b41bECbC3"

# Address of the token this contract will distribute (e.g., cUSD, cEUR, or a custom token)
REWARD_TOKEN_ADDRESS="0x..."
