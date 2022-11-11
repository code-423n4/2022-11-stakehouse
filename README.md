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

## C4udit / Publicly Known Issues

The C4audit output for the contest can be found [here](https://gist.github.com/Picodes/b7428629484c8aa937b2606f21623151).

*Note for C4 wardens: Anything included in the C4udit output is considered a publicly known issue and is ineligible for awards.*

# Commit

https://github.com/code-423n4/2022-11-stakehouse/commit/5f853d055d7aa1bebe9e24fd0e863ef58c004339

# Video Walkthrough + External documentation

Walkthrough: https://www.youtube.com/watch?v=7UHDUA9l6Ek

Documentation: https://docs.google.com/document/d/1ipeaj74kWQZNq-FZ1QD9DLoiz5vRnx-_thzCNBuuRpM/edit?usp=sharing

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

Due to stack too deep issues which are being looked into, the respective column could not be filled.

### Files in scope
|File|[SLOC](#nowhere "(nSLOC, SLOC, Lines)")|[Coverage](#nowhere "(Lines hit / Total)")|
|:-|:-:|:-:|
|_Contracts (18)_|
|[contracts/liquid-staking/OptionalGatekeeperFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/OptionalGatekeeperFactory.sol) [🌀](#nowhere "create/create2")|[10](#nowhere "(nSLOC:10, SLOC:10, Lines:18)")|-|
|[contracts/liquid-staking/OptionalHouseGatekeeper.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/OptionalHouseGatekeeper.sol)|[12](#nowhere "(nSLOC:12, SLOC:12, Lines:22)")|-|
|[contracts/liquid-staking/SavETHVaultDeployer.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVaultDeployer.sol) [🌀](#nowhere "create/create2")|[17](#nowhere "(nSLOC:17, SLOC:17, Lines:26)")|-|
|[contracts/liquid-staking/StakingFundsVaultDeployer.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVaultDeployer.sol) [🌀](#nowhere "create/create2")|[17](#nowhere "(nSLOC:17, SLOC:17, Lines:26)")|-|
|[contracts/smart-wallet/OwnableSmartWalletFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWalletFactory.sol) [🌀](#nowhere "create/create2")|[26](#nowhere "(nSLOC:26, SLOC:26, Lines:45)")|-|
|[contracts/liquid-staking/LPTokenFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LPTokenFactory.sol)|[30](#nowhere "(nSLOC:25, SLOC:30, Lines:49)")|-|
|[contracts/liquid-staking/GiantLP.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantLP.sol)|[33](#nowhere "(nSLOC:33, SLOC:33, Lines:48)")|-|
|[contracts/liquid-staking/LPToken.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LPToken.sol)|[44](#nowhere "(nSLOC:39, SLOC:44, Lines:71)")|-|
|[contracts/syndicate/SyndicateFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/SyndicateFactory.sol) [🧮](#nowhere "Uses Hash-Functions")|[44](#nowhere "(nSLOC:31, SLOC:44, Lines:65)")|-|
|[contracts/liquid-staking/GiantPoolBase.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantPoolBase.sol) [💰](#nowhere "Payable Functions") [📤](#nowhere "Initiates ETH Value Transfer")|[53](#nowhere "(nSLOC:53, SLOC:53, Lines:104)")|-|
|[contracts/liquid-staking/LSDNFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LSDNFactory.sol)|[66](#nowhere "(nSLOC:61, SLOC:66, Lines:103)")|-|
|[contracts/liquid-staking/GiantSavETHVaultPool.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantSavETHVaultPool.sol) [📤](#nowhere "Initiates ETH Value Transfer") [🌀](#nowhere "create/create2")|[101](#nowhere "(nSLOC:83, SLOC:101, Lines:158)")|-|
|[contracts/smart-wallet/OwnableSmartWallet.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWallet.sol) [💰](#nowhere "Payable Functions")|[107](#nowhere "(nSLOC:60, SLOC:107, Lines:151)")|-|
|[contracts/liquid-staking/SavETHVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVault.sol) [💰](#nowhere "Payable Functions")|[144](#nowhere "(nSLOC:141, SLOC:144, Lines:249)")|-|
|[contracts/liquid-staking/GiantMevAndFeesPool.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantMevAndFeesPool.sol) [📤](#nowhere "Initiates ETH Value Transfer") [🌀](#nowhere "create/create2")|[149](#nowhere "(nSLOC:127, SLOC:149, Lines:205)")|-|
|[contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol) [💰](#nowhere "Payable Functions")|[246](#nowhere "(nSLOC:239, SLOC:246, Lines:382)")|-|
|[contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol) [💰](#nowhere "Payable Functions") [📤](#nowhere "Initiates ETH Value Transfer")|[402](#nowhere "(nSLOC:374, SLOC:402, Lines:681)")|-|
|[contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol) [💰](#nowhere "Payable Functions")|[602](#nowhere "(nSLOC:534, SLOC:602, Lines:946)")|-|
|_Abstracts (2)_|
|[contracts/liquid-staking/SyndicateRewardsProcessor.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SyndicateRewardsProcessor.sol) [💰](#nowhere "Payable Functions")|[60](#nowhere "(nSLOC:49, SLOC:60, Lines:99)")|-|
|[contracts/liquid-staking/ETHPoolLPFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/ETHPoolLPFactory.sol)|[85](#nowhere "(nSLOC:81, SLOC:85, Lines:152)")|-|
|_Other (1)_|
|[contracts/syndicate/SyndicateErrors.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/SyndicateErrors.sol)|[21](#nowhere "(nSLOC:21, SLOC:21, Lines:24)")|-|
|Total (over 21 files):| [2269](#nowhere "(nSLOC:2033, SLOC:2269, Lines:3624)")| -|


### All other source contracts (not in scope)
|File|[SLOC](#nowhere "(nSLOC, SLOC, Lines)")|[Coverage](#nowhere "(Lines hit / Total)")|
|:-|:-:|:-:|
|_Interfaces (10)_|
|[contracts/interfaces/IGateKeeper.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/IGateKeeper.sol)|[4](#nowhere "(nSLOC:4, SLOC:4, Lines:10)")|-|
|[contracts/interfaces/ILiquidStakingManagerChildContract.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ILiquidStakingManagerChildContract.sol)|[4](#nowhere "(nSLOC:4, SLOC:4, Lines:7)")|-|
|[contracts/interfaces/IBrandNFT.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/IBrandNFT.sol)|[5](#nowhere "(nSLOC:5, SLOC:5, Lines:8)")|-|
|[contracts/interfaces/ITransferHookProcessor.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ITransferHookProcessor.sol)|[5](#nowhere "(nSLOC:5, SLOC:5, Lines:8)")|-|
|[contracts/interfaces/ILPTokenInit.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ILPTokenInit.sol)|[9](#nowhere "(nSLOC:4, SLOC:9, Lines:13)")|-|
|[contracts/interfaces/ISyndicateInit.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ISyndicateInit.sol)|[9](#nowhere "(nSLOC:4, SLOC:9, Lines:13)")|-|
|[contracts/smart-wallet/interfaces/IOwnableSmartWalletFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/interfaces/IOwnableSmartWalletFactory.sol)|[9](#nowhere "(nSLOC:9, SLOC:9, Lines:14)")|-|
|[contracts/interfaces/ILiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ILiquidStakingManager.sol)|[19](#nowhere "(nSLOC:7, SLOC:19, Lines:37)")|-|
|[contracts/interfaces/ISyndicateFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/interfaces/ISyndicateFactory.sol)|[20](#nowhere "(nSLOC:7, SLOC:20, Lines:41)")|-|
|[contracts/smart-wallet/interfaces/IOwnableSmartWallet.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/interfaces/IOwnableSmartWallet.sol) [💰](#nowhere "Payable Functions")|[32](#nowhere "(nSLOC:18, SLOC:32, Lines:69)")|-|
|Total (over 10 files):| [116](#nowhere "(nSLOC:67, SLOC:116, Lines:220)")| -|


## External imports
* **@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/IDataStructures.sol**
  * [contracts/liquid-staking/ETHPoolLPFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/ETHPoolLPFactory.sol)
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/liquid-staking/SavETHVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVault.sol)
  * [contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol)
* **@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/IStakeHouseRegistry.sol**
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
* **@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/ITransactionRouter.sol**
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
* **@blockswaplab/stakehouse-solidity-api/contracts/StakehouseAPI.sol**
  * [contracts/liquid-staking/ETHPoolLPFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/ETHPoolLPFactory.sol)
  * [contracts/liquid-staking/GiantSavETHVaultPool.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantSavETHVaultPool.sol)
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol)
  * [contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol)
* **@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol**
  * [contracts/liquid-staking/LPToken.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LPToken.sol)
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/liquid-staking/SavETHVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVault.sol)
  * [contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol)
  * [contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol)
* **@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol**
  * [contracts/liquid-staking/LPToken.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LPToken.sol)
* **@openzeppelin/contracts/access/Ownable.sol**
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/smart-wallet/OwnableSmartWallet.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWallet.sol)
  * [contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol)
* **@openzeppelin/contracts/proxy/Clones.sol**
  * [contracts/liquid-staking/LPTokenFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LPTokenFactory.sol)
  * [contracts/liquid-staking/LSDNFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LSDNFactory.sol)
  * [contracts/liquid-staking/SavETHVaultDeployer.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVaultDeployer.sol)
  * [contracts/liquid-staking/StakingFundsVaultDeployer.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVaultDeployer.sol)
  * [contracts/smart-wallet/OwnableSmartWalletFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWalletFactory.sol)
  * [contracts/syndicate/SyndicateFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/SyndicateFactory.sol)
* **@openzeppelin/contracts/proxy/utils/Initializable.sol**
  * [contracts/smart-wallet/OwnableSmartWallet.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWallet.sol)
* **@openzeppelin/contracts/security/ReentrancyGuard.sol**
  * [contracts/liquid-staking/GiantPoolBase.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantPoolBase.sol)
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/liquid-staking/SavETHVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/SavETHVault.sol)
  * [contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol)
  * [contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol)
* **@openzeppelin/contracts/token/ERC20/ERC20.sol**
  * [contracts/liquid-staking/GiantLP.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/GiantLP.sol)
* **@openzeppelin/contracts/token/ERC20/IERC20.sol**
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/liquid-staking/StakingFundsVault.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/StakingFundsVault.sol)
  * [contracts/syndicate/Syndicate.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/syndicate/Syndicate.sol)
* **@openzeppelin/contracts/utils/Address.sol**
  * [contracts/liquid-staking/LiquidStakingManager.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/LiquidStakingManager.sol)
  * [contracts/smart-wallet/OwnableSmartWallet.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/smart-wallet/OwnableSmartWallet.sol)
* **@openzeppelin/contracts/utils/Strings.sol**
  * [contracts/liquid-staking/ETHPoolLPFactory.sol](https://github.com/code-423n4/2022-11-stakehouse/blob/main/contracts/liquid-staking/ETHPoolLPFactory.sol)

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
- Total SLoC for these contracts?: 2269
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

# Quickstart command

`rm -Rf 2022-11-stakehouse || true && git clone https://github.com/code-423n4/2022-11-stakehouse.git && cd 2022-11-stakehouse && yarn install && yarn test --gas-report`

# Installing Dependencies

`yarn` or `yarn install` will do the trick.

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
