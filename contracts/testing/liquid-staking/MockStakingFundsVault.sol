// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISavETHManager } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/ISavETHManager.sol";
import { IAccountManager } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/IAccountManager.sol";

import { LiquidStakingManager } from "../../liquid-staking/LiquidStakingManager.sol";
import { LPTokenFactory } from "../../liquid-staking/LPTokenFactory.sol";
import { StakingFundsVault } from "../../liquid-staking/StakingFundsVault.sol";
import { MockSavETHRegistry } from "../stakehouse/MockSavETHRegistry.sol";
import { MockAccountManager } from "../stakehouse/MockAccountManager.sol";
import { IFactoryDependencyInjector } from "../interfaces/IFactoryDependencyInjector.sol";

contract MockStakingFundsVault is StakingFundsVault {

    MockSavETHRegistry public saveETHRegistry;
    MockAccountManager public accountMan;
    IERC20 public dETHToken;

    function init(address _liquidStakingManagerAddress, LPTokenFactory _tokenFactory) external override {
        IFactoryDependencyInjector dependencyInjector = IFactoryDependencyInjector(
            LiquidStakingManager(payable(_liquidStakingManagerAddress)).dao()
        );

        dETHToken = IERC20(dependencyInjector.dETH());
        saveETHRegistry = MockSavETHRegistry(dependencyInjector.saveETHRegistry());
        accountMan = MockAccountManager(dependencyInjector.accountMan());

        saveETHRegistry.setDETHToken(dETHToken);

        _init(LiquidStakingManager(payable(_liquidStakingManagerAddress)), _tokenFactory);
    }

    /// ----------------------
    /// Override Solidity API
    /// ----------------------

    function getSavETHRegistry() internal view override returns (ISavETHManager) {
        return ISavETHManager(address(saveETHRegistry));
    }

    function getAccountManager() internal view override returns (IAccountManager accountManager) {
        return IAccountManager(address(accountMan));
    }

    function getDETH() internal view override returns (IERC20 dETH) {
        return dETHToken;
    }
}