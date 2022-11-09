pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { ILiquidStakingManager } from "../interfaces/ILiquidStakingManager.sol";

/// @notice Contract for deploying a new Liquid Staking Derivative Network (LSDN)
contract LSDNFactory {

    /// @notice Emitted when a new liquid staking manager is deployed
    event LSDNDeployed(address indexed LiquidStakingManager);

    /// @notice Address of the liquid staking manager implementation that is cloned on each deployment
    address public liquidStakingManagerImplementation;

    /// @notice Address of the factory that will deploy a syndicate for the network after the first knot is created
    address public syndicateFactory;

    /// @notice Address of the factory for deploying LP tokens in exchange for ETH supplied to stake a KNOT
    address public lpTokenFactory;

    /// @notice Address of the factory for deploying smart wallets used by node runners during staking
    address public smartWalletFactory;

    /// @notice Address of brand NFT
    address public brand;

    /// @notice Address of the contract that can deploy new instances of SavETHVault
    address public savETHVaultDeployer;

    /// @notice Address of the contract that can deploy new instances of StakingFundsVault
    address public stakingFundsVaultDeployer;

    /// @notice Address of the contract that can deploy new instances of optional gatekeepers for controlling which knots can join the LSDN house
    address public optionalGatekeeperDeployer;

    /// @notice Establishes whether a given liquid staking manager address was deployed by this factory
    mapping(address => bool) public isLiquidStakingManager;

    constructor(
        address _liquidStakingManagerImplementation,
        address _syndicateFactory,
        address _lpTokenFactory,
        address _smartWalletFactory,
        address _brand,
        address _savETHVaultDeployer,
        address _stakingFundsVaultDeployer,
        address _optionalGatekeeperDeployer
    ) {
        require(_liquidStakingManagerImplementation != address(0), "Zero Address");
        require(_syndicateFactory != address(0), "Zero Address");
        require(_lpTokenFactory != address(0), "Zero Address");
        require(_smartWalletFactory != address(0), "Zero Address");
        require(_brand != address(0), "Zero Address");
        require(_savETHVaultDeployer != address(0), "Zero Address");
        require(_stakingFundsVaultDeployer != address(0), "Zero Address");
        require(_optionalGatekeeperDeployer != address(0), "Zero Address");

        liquidStakingManagerImplementation = _liquidStakingManagerImplementation;
        syndicateFactory = _syndicateFactory;
        lpTokenFactory = _lpTokenFactory;
        smartWalletFactory = _smartWalletFactory;
        brand = _brand;
        savETHVaultDeployer = _savETHVaultDeployer;
        stakingFundsVaultDeployer = _stakingFundsVaultDeployer;
        optionalGatekeeperDeployer = _optionalGatekeeperDeployer;
    }

    /// @notice Deploys a new LSDN and the liquid staking manger required to manage the network
    /// @param _dao Address of the entity that will govern the liquid staking network
    /// @param _stakehouseTicker Liquid staking derivative network ticker (between 3-5 chars)
    function deployNewLiquidStakingDerivativeNetwork(
        address _dao,
        uint256 _optionalCommission,
        bool _deployOptionalHouseGatekeeper,
        string calldata _stakehouseTicker
    ) public returns (address) {

        // Clone a new liquid staking manager instance
        address newInstance = Clones.clone(liquidStakingManagerImplementation);
        ILiquidStakingManager(newInstance).init(
            _dao,
            syndicateFactory,
            smartWalletFactory,
            lpTokenFactory,
            brand,
            savETHVaultDeployer,
            stakingFundsVaultDeployer,
            optionalGatekeeperDeployer,
            _optionalCommission,
            _deployOptionalHouseGatekeeper,
            _stakehouseTicker
        );

        // Record that the manager was deployed by this contract
        isLiquidStakingManager[newInstance] = true;

        emit LSDNDeployed(newInstance);

        return newInstance;
    }
}