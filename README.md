# LSD Network - Stakehouse contest details
- Total Prize Pool: $90,500 USDC
  - HM awards: $63,750 USDC 
  - QA report awards: $7,500 USDC 
  - Gas report awards: $3,750 USDC
  - Judge + presort awards: $15,000 USDC 
  - Scout awards: $500 USDC
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code4rena.com/contests/2022-11-lsd-network-stakehouse-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts November 11, 2022 20:00 UTC
- Ends November 18, 2022 20:00 UTC

# Video Walkthrough

https://www.youtube.com/watch?v=7UHDUA9l6Ek

# Overview

Liquid Staking Derivative (LSD) Networks are permissionless networks deployed on top of the Stakehouse protocol that serves as an abstraction for consensus layer assets. LSD participants can enjoy fractionalized validator ownership with deposits as little as 0.001 ether. 

Liquidity provisioning is made easier thanks to giant liquidity pools that can supply the ether required for any validator being created in any liquid staking network. Stakehouse protocol derivatives minted within LSDs all benefit from shared dETH liquidity allowing for maximum Ethereum decentralization whilst the rising tide of dETH liquidity raises all boats.

Blockswap Labs is the core contributor of the Liquid Staking Derivatives suite of contracts and is heavily testing the smart contracts in parallel to any external efforts to find and fix bugs as safety of user's funds prevails above launching a new offering.

## Contracts overview
<img width="1222" alt="image" src="https://user-images.githubusercontent.com/70540321/199479093-ec45cadd-91d7-47f0-811f-1d0016b95189.png">

LSD network instances are instantiated from the LSD network factory. This will deploy the contracts required for the operation of a LSD network:
- SavETH Vault - protected staking vault where up to 24 ETH per validator can be staked for dETH 
- Staking Funds - Staking funds for fees and MEV collecting 50% of all cashflow from EIP1559

Contracts deployed on demand:
- Node Runner smart wallets for facilitating Ethereum Deposit Contract staking via the Stakehouse protocol
- Syndicate for facilitating distribution of EIP1559 rewards 50% to node runners and 50% to the Staking Funds Vault
- LP tokens for either Giant pool liquidity or liquidity for individual LSD networks

## Mechanics and design - 3 pool strategy for curating 32 ETH
Node runners can register a validator BLS public key if they supply `4 ETH`.

For every registered BLS public key, rest of the ETH is crowd sourced as follows:
- SavETH Vault - users can pool up to `24 ETH` where protected staking ensures no-loss. dETH can be redeemed after staking
- Staking funds vault - users can pool up to `4 ETH` where the user's share of LP token will entitle them to a percentage of half of all network revenue

Once the 3 pool strategy reaches its 32 ETH target per validator, node runners can proceed to trigger sending of the queued funds to the Ethereum Deposit Contract after being registered by the Stakehouse protocol. 

Finally, once certified by the beacon chain, Stakehouse protocol derivatives can be minted which automatically takes care of a number of actions:
- Allocate savETH <> dETH to `savETH Vault` (24 dETH)
- Register validator to syndicate so that the node runner can get 50% of network revenue and staking funds LPs can get a pro rata share of the other 50% thanks to SLOT tokens

All 3 pools own a fraction of a regular 32 ETH validator with the consensus and network revenue split amongst the 3 pools.

## Flow for creating an LSD validator within the Stakehouse protocol

1) Node runner registers validator credentials and supplies first 4 ETH
2) SavETH Vault and Staking Funds Vault fills up with ETH for the KNOT until total of 32 ETH is reached (if needed, liquidity from Giant pool can be sourced)
3) Node runner with their representative stake the validator
4) After Consensus Layer approves validator, derivatives can be minted

## Node runner risks

Node runners must supply exactly 4 ETH per validator credentials in order to shield the protocol from risks of mismanaging node. Should there be an error in node running, the node runner's capital is at risk of being slashed by anyone on the market via the Stakehouse protocol.

# Scope

*List all files in scope in the table below -- and feel free to add notes here to emphasize areas of focus.*

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| contrats/liquid-staking/ETHPoolLPFactory.sol | 85 | Factory for deploying LP tokens for ETH pools | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/GiantLP.sol | 33 | LP token minted for supplying ETH to a Giant pool | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/GiantMevAndFeesPool.sol | 149 | ETH pool that can deploy capital to any LSD Staking Funds Vault | N/A |
| contrats/liquid-staking/GiantPoolBase.sol | 53 | Base contract inherited by both Giant pools | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/GiantSavETHVaultPool.sol | 101 | ETH pool that can deploy capital to any LSD SavETH Vault | [`@blockswaplab/stakehouse-solidity-api/*`](https://www.npmjs.com/package/@blockswaplab/stakehouse-solidity-api/) |
| contrats/liquid-staking/LiquidStakingManager.sol | 602 | Central orchestrator for any LSD instance managing full lifecycle of staking and interacting with the Stakehouse protocol | [`@openzeppelin/*`](https://openzeppelin.com/contracts) [`@blockswaplab/stakehouse-solidity-api/*`](https://www.npmjs.com/package/@blockswaplab/stakehouse-solidity-api/) |
| contrats/liquid-staking/LPToken.sol | 44 | Token minted when ETH is deposited for a specific LSD instance | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/LPTokenFactory.sol | 30 | Factory for deploying new LP token instances | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/LSDNFactory.sol | 66 | Factory for deploying new LSD instances including its Liquid Staking Manager | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/OptionalGatekeeperFactory.sol | 10 | Factory for deploying an optional gatekeeper that will prevent KNOTs outside of the LSD network from joining the house | N/A |
| contrats/liquid-staking/OptionalHouseGatekeeper.sol | 12 | If enabled for an LSD instance, it will only allow knots that are registered in the LSD to join the house | N/A |
| contrats/liquid-staking/SavETHVault.sol | 144 | Contract for facilitating protected deposits of ETH for dETH once each KNOT mints it's derivatives | [`@openzeppelin/*`](https://openzeppelin.com/contracts) [`@blockswaplab/stakehouse-solidity-api/*`](https://www.npmjs.com/package/@blockswaplab/stakehouse-solidity-api/) |
| contrats/liquid-staking/SavETHVaultDeployer.sol | 17 | Can deploy multiple instances of SavETH Vault | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/StakingFundsVault.sol | 246 | Contract for facilitating deposits of ETH for LSD network. The LP token issued from the Staking Funds Vault can claim a pro rata share of network revenue | [`@openzeppelin/*`](https://openzeppelin.com/contracts) [`@blockswaplab/stakehouse-solidity-api/*`](https://www.npmjs.com/package/@blockswaplab/stakehouse-solidity-api/) |
| contrats/liquid-staking/StakingFundsVaultDeployer.sol | 17 | Can deploy multiple instances of Staking Funds Vault | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/liquid-staking/SyndicateRewardsProcessor.sol | 60 | Abstract contract for managing the receipt of ETH from a Syndicate contract and distributing it amongst LP tokens whilst ensuring that flash loans cannot claim ETH in same block | N/A |
| contrats/smart-wallet/OwnableSmartWallet.sol | 107 | Generic wallet which can be used in conjunction with the Stakehouse protocol for staking; making collateralized SLOT tokens governable | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/smart-wallet/OwnableSmartWalletFactory.sol | 26 | Factory for deploying a smart wallet | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/syndicate/Syndicate.sol | 402 | Splitting ETH amongst KNOT SLOT shares (free floating and collateralized) | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |
| contrats/syndicate/SyndicateErrors.sol | 21 | Contract for storing all Solidity errors for Syndicate | N/A |
| contrats/syndicate/SyndicateFactory.sol | 44 | Contract for deploying new syndicate contract instances | [`@openzeppelin/*`](https://openzeppelin.com/contracts) |

## Out of scope

*List any files/contracts that are out of scope for this audit.*

## Objectives

Approach
- Formal Verification of LSDN
- Fuzzing
- Unit Tests
- Manual inspection

Categories of vulnerabilities to think about:
- Pool draining attacks (draining liquidity of Giant pools or an LSD instance)
- Contract accounting deviating from intended specification
- Syndicate ETH fund splitting failures i.e. being able to claim more than stake weight or claim more than once etc.
- DAO compromised
- External protocols - what happens when an external protocol is integrated? Flash loans broke a lot of protocols

# Additional Context

A bit of background on formal verification tools. 

Invariant - some property that holds irrespective of the contract state.

Example: Let’s take the ERC20 contract where each account has a balance. ERC20 contract also has the total supply which should be the sum of all the balances (no money is created or deleted out of nowhere), hence here we have the following invariant:

English invariant: Sum of all balances == totalSupply

Or in mathematical notation we can denote bi as the balance of i’th account, and T the total supply:

Invariant: i bi = T

In this case the invariant test would be the following (pseudocode):

Set the contract state to i bi = T
Call a function f on the smart contract
Check if i bi = T still holds after the function call

Here if the invariant is violated obviously the contract just reached the state it should not.

Some properties suggested by the core contributors from Blockswap Labs:

- Property #1: The sum of all provided ETH by SavETH Vault == to the number of LP tokens minted in total for all the KNOTs

- Property #2: LP token rotation is only possible if both the KNOTs are in status Initials Registered

- Property #3: Rotated LP preference conserves the LP quantity (no new tokens created or destroyed)

- Property #4: LP token total supply should be capped at 24 ETH

- Property #5: Sum of all LP tokens of non-deposited BLS keys == ETH balance of the smart contract

- Property #6: Each BLS public key can only be associated with 1 LP token

Existing Certora rules which are being expanded and looked into can be found in the `certora/` folder within the repository.

## Scoping Details 
```
- If you have a public code repo, please share it here: https://github.com/stakehouse-dev/lsd-arena
- How many contracts are in scope?: 25
- Total SLoC for these contracts?: 3000
- How many external imports are there?: 5
- How many separate interfaces and struct definitions are there for the contracts within scope?: 8
- Does most of your code generally use composition or inheritance?:  Composition
- How many external calls?:  5 
- What is the overall line coverage percentage provided by your tests?:  In Progress
- Is there a need to understand a separate part of the codebase / get context in order to audit this part of the protocol?: Yes  
- Please describe required context:  Stakehouse protocol and Ethereum staking
- Does it use an oracle?: No
- Does the token conform to the ERC20 standard?:  Yes
- Are there any novel or unique curve logic or mathematical models?: No
- Does it use a timelock function?:  No
- Is it an NFT?: No
- Does it have an AMM?:  No
- Is it a fork of a popular project?:  No 
- Does it use rollups?: No
- Is it multi-chain?: Yes
- Does it use a side-chain?: No
```

# Tests

Foundry tests can be run with the following command:
```
yarn test
```

If anything requires more verbose logging, then the following can be run:
```
yarn test-debug
```

Coverage is a possibility but not fully stable yet due to Solidity stack too deep issues which are being actively looked into.

The `contracts/testing` folder contains mock versions of some of the LSD network contracts but also mock versions of the Stakehouse protocol contracts used in the testing of the protocol in order to facilitate testing without the external dependency. Of course, foundry tests can be written to execute tests on a fork of the goerli or mainnet contracts that are currently deployed. 
