// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ISavETHManager } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/ISavETHManager.sol";
import { IAccountManager } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/IAccountManager.sol";
import { SavETHVault } from "../../liquid-staking/SavETHVault.sol";
import { LPTokenFactory } from "../../liquid-staking/LPTokenFactory.sol";
import { LiquidStakingManager } from "../../liquid-staking/LiquidStakingManager.sol";
import { MockSavETHRegistry } from "../stakehouse/MockSavETHRegistry.sol";
import { MockAccountManager } from "../stakehouse/MockAccountManager.sol";
import { IFactoryDependencyInjector } from "../interfaces/IFactoryDependencyInjector.sol";
import { LPToken } from "../../liquid-staking/LPToken.sol";

contract MockSavETHVault is SavETHVault {

    MockSavETHRegistry public saveETHRegistry;
    MockAccountManager public accountMan;
    IERC20 public dETHToken;

    function init(address _liquidStakingManagerAddress, LPTokenFactory _lpTokenFactory) external override {

        IFactoryDependencyInjector dependencyInjector = IFactoryDependencyInjector(
            LiquidStakingManager(payable(_liquidStakingManagerAddress)).dao()
        );

        dETHToken = IERC20(dependencyInjector.dETH());
        saveETHRegistry = MockSavETHRegistry(dependencyInjector.saveETHRegistry());
        accountMan = MockAccountManager(dependencyInjector.accountMan());

        saveETHRegistry.setDETHToken(dETHToken);

        _init(_liquidStakingManagerAddress, _lpTokenFactory);
    }

    function getBalance(address _account) public view returns (uint256) {
        return _account.balance;
    }

    // This function is added to test the contract state
    // Refer: SavETHVault.spec rule shouldWithdrawETHForStaking
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getLPTokenBalanceByBLSPublicKey(bytes calldata _blsPublicKey, address _userAddress) public view returns (uint256) {
        LPToken token = lpTokenForKnot[_blsPublicKey];
        return token.balanceOf(_userAddress);
    }

    function getTotalSupplyOfLPTokenByBLSPublicKey(bytes calldata _blsPublicKey) public view returns (uint256) {
        LPToken token = lpTokenForKnot[_blsPublicKey];
        return token.totalSupply();
    }

    function getDETHBalanceOfUser(address _userAddress) public view returns (uint256) {
        return dETHToken.balanceOf(_userAddress);
    }

    function getLifecycleStatusOfBLSPublicKey(bytes calldata _blsPublicKey) public view returns (uint256) {
        return accountMan.blsPublicKeyToLifecycleStatus(_blsPublicKey);
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