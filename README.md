# Sats Swap 🛰️

A modular, minimal Decentralized Exchange (DEX) built with Solidity and Foundry. 

## 📌 Overview
Sats Swap is an Automated Market Maker (AMM) that utilizes the Constant Product Formula ($x * y = k$) to facilitate decentralized token swaps. It is designed with a strictly modular architecture, separating core math, factory management, and user routing.

## 🏗️ Architecture
The project is divided into three primary components:

* **SatsSwapPair**: The core engine. Handles the math, tracks reserves, and executes token transfers.
* **SatsSwapFactory**: The registry. Deploys new pair contracts and maintains a mapping of all existing pairs.
* **SatsSwapRouter**: The entry point. A high-level contract that simplifies user interactions by finding pairs and managing multi-step approvals.

## 🚀 Technical Stack
* **Language:** Solidity ^0.8.20
* **Framework:** Foundry (Forge)
* **Standard:** ERC-20 (Mock implementations included for testing)

## 🛠️ Getting Started

### Prerequisites
Ensure you have [Foundry](https://getfoundry.sh/) installed on your system.

### Installation
```
git clone https://github.com/srimadhavsats/sats-swap.git
cd sats-swap
forge install
```

### Testing
```
forge test -vv
```
