pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { GiantSavETHVaultPool } from "../../liquid-staking/GiantSavETHVaultPool.sol";
import { LSDNFactory } from "../../liquid-staking/LSDNFactory.sol";

contract MockGiantSavETHVaultPool is GiantSavETHVaultPool {

    IERC20 dETHToken;

    constructor(
        LSDNFactory _factory,
        IERC20 _dETH
    ) GiantSavETHVaultPool(_factory) {
        dETHToken = _dETH;
    }

    /// ----------------------
    /// Override Solidity API
    /// ----------------------

    function getDETH() internal view override returns (IERC20 dETH) {
        return dETHToken;
    }
}