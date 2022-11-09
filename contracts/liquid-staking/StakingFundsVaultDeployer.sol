// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { StakingFundsVault } from "./StakingFundsVault.sol";
import { LPTokenFactory } from "./LPTokenFactory.sol";

contract StakingFundsVaultDeployer {

    event NewVaultDeployed(address indexed instance);

    address implementation;
    constructor() {
        implementation = address(new StakingFundsVault());
    }

    function deployStakingFundsVault(address _liquidStakingManager, address _tokenFactory) external returns (address) {
        address newVault = Clones.clone(implementation);

        StakingFundsVault(payable(newVault)).init(_liquidStakingManager, LPTokenFactory(_tokenFactory));
        emit NewVaultDeployed(newVault);

        return newVault;
    }
}