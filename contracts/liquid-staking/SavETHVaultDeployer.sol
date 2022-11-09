pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { SavETHVault } from "./SavETHVault.sol";
import { LPTokenFactory } from "./LPTokenFactory.sol";

contract SavETHVaultDeployer {

    event NewVaultDeployed(address indexed instance);

    address implementation;
    constructor() {
        implementation = address(new SavETHVault());
    }

    function deploySavETHVault(address _liquidStakingManger, address _lpTokenFactory) external returns (address) {
        address newVault = Clones.clone(implementation);

        SavETHVault(newVault).init(_liquidStakingManger, LPTokenFactory(_lpTokenFactory));
        emit NewVaultDeployed(newVault);

        return newVault;
    }
}