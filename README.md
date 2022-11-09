# ✨ So you want to sponsor a contest

This `README.md` contains a set of checklists for our contest collaboration.

Your contest will use two repos: 
- **a _contest_ repo** (this one), which is used for scoping your contest and for providing information to contestants (wardens)
- **a _findings_ repo**, where issues are submitted (shared with you after the contest) 

Ultimately, when we launch the contest, this contest repo will be made public and will contain the smart contracts to be reviewed and all the information needed for contest participants. The findings repo will be made public after the contest report is published and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the contest sponsor (⭐️)**.

---

# Contest setup

# Repo setup

## ⭐️ Sponsor: Add code to this repo

- [ ] Create a PR to this repo with the below changes:
- [ ] Provide a self-contained repository with working commands that will build (at least) all in-scope contracts, and commands that will run tests producing gas reports for the relevant contracts.
- [x] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 24 hours prior to contest start time.**
- [ ] Be prepared for a 🚨code freeze🚨 for the duration of the contest — important because it establishes a level playing field. We want to ensure everyone's looking at the same code, no matter when they look during the contest. (Note: this includes your own repo, since a PR can leak alpha to our wardens!)


---

## ⭐️ Sponsor: Edit this README

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2022-08-foundation#readme))
  - [ ] When linking, please provide all links as full absolute links versus relative links
  - [ ] All information should be provided in markdown format (HTML does not render on Code4rena.com)
- [ ] Under the "Scope" heading, provide the name of each contract and:
  - [ ] source lines of code (excluding blank lines and comments) in each
  - [ ] external contracts called in each
  - [ ] libraries used in each
- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [ ] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
- [ ] Optional / nice to have: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Delete this checklist and all text above the line below when you're ready.

---

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

The C4audit output for the contest can be found [here](add link to report) within an hour of contest opening.

*Note for C4 wardens: Anything included in the C4udit output is considered a publicly known issue and is ineligible for awards.*

[ ⭐️ SPONSORS ADD INFO HERE ]

# Overview

*Please provide some context about the code being audited, and identify any areas of specific concern in reviewing the code. (This is a good place to link to your docs, if you have them.)*

# Scope

*List all files in scope in the table below -- and feel free to add notes here to emphasize areas of focus.*

| Contract | SLOC | Purpose | Libraries used |  
| ----------- | ----------- | ----------- | ----------- |
| contrats/liquid-staking/ETHPoolLPFactory.sol | 85 | Factory for deploying LP tokens for ETH pools | [`@openzeppelin/*`](<(https://openzeppelin.com/contracts/)>) |
| contrats/liquid-staking/GiantLP.sol | 33 | LP token minted for supplying ETH to a Giant pool | TODO |
| contrats/liquid-staking/GiantMevAndFeesPool.sol | 149 | ETH pool that can deploy capital to any LSD Staking Funds Vault | TODO |
| contrats/liquid-staking/GiantPoolBase.sol | 53 | Base contract inherited by both Giant pools |  |
| contrats/liquid-staking/GiantSavETHVaultPool.sol | 101 | ETH pool that can deploy capital to any LSD SavETH Vault | TODO |
| contrats/liquid-staking/LiquidStakingManager.sol | 602 | Central orchestrator for any LSD instance managing full lifecycle of staking and interacting with the Stakehouse protocol | TODO |
| contrats/liquid-staking/LPToken.sol | 44 | Token minted when ETH is deposited for a specific LSD instance | TODO |
| contrats/liquid-staking/LPTokenFactory.sol | 30 | Factory for deploying new LP token instances | TODO |
| contrats/liquid-staking/LSDNFactory.sol | 66 | Factory for deploying new LSD instances including its Liquid Staking Manager | TODO |
| contrats/liquid-staking/OptionalGatekeeperFactory.sol | 10 | Factory for deploying an optional gatekeeper that will prevent KNOTs outside of the LSD network from joining the house | TODO |
| contrats/liquid-staking/OptionalHouseGatekeeper.sol | 12 | If enabled for an LSD instance, it will only allow knots that are registered in the LSD to join the house | TODO |
| contrats/liquid-staking/SavETHVault.sol | 144 | Contract for facilitating protected deposits of ETH for dETH once each KNOT mints it's derivatives | TODO |
| contrats/liquid-staking/SavETHVaultDeployer.sol | 17 | Can deploy multiple instances of SavETH Vault | TODO |
| contrats/liquid-staking/StakingFundsVault.sol | 246 | Contract for facilitating deposits of ETH for LSD network. The LP token issued from the Staking Funds Vault can claim a pro rata share of network revenue | TODO |
| contrats/liquid-staking/StakingFundsVaultDeployer.sol | 17 | Can deploy multiple instances of Staking Funds Vault | TODO |
| contrats/liquid-staking/SyndicateRewardsProcessor.sol | 60 | Abstract contract for managing the receipt of ETH from a Syndicate contract and distributing it amongst LP tokens whilst ensuring that flash loans cannot claim ETH in same block | TODO |
| contrats/smart-wallet/OwnableSmartWallet.sol | 107 | Generic wallet which can be used in conjunction with the Stakehouse protocol for staking; making collateralized SLOT tokens governable | TODO |
| contrats/smart-wallet/OwnableSmartWalletFactory.sol | 26 | Factory for deploying a smart wallet | TODO |
| contrats/syndicate/Syndicate.sol | 402 | Splitting ETH amongst KNOT SLOT shares (free floating and collateralized) | TODO |
| contrats/syndicate/SyndicateErrors.sol | 21 | Contract for storing all Solidity errors for Syndicate | TODO |
| contrats/syndicate/SyndicateFactory.sol | 44 | Contract for deploying new syndicate contract instances | TODO |

## Out of scope

*List any files/contracts that are out of scope for this audit.*

# Additional Context

*Describe any novel or unique curve logic or mathematical models implemented in the contracts*

*Please confirm/edit the scoping details below.*

## Scoping Details 
```
- If you have a public code repo, please share it here: https://github.com/stakehouse-dev/lsd-arena
- How many contracts are in scope?: 25
- Total SLoC for these contracts?: 2500
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

*Provide every step required to build the project from a fresh git clone, as well as steps to run the tests with a gas report.* 

*Note: Many wardens run Slither as a first pass for testing.  Please document any known errors with no workaround.* 
