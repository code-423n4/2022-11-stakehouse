pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { ISyndicateFactory } from "../interfaces/ISyndicateFactory.sol";
import { ISyndicateInit } from "../interfaces/ISyndicateInit.sol";

/// @notice Contract for deploying a new KNOT syndicate
contract SyndicateFactory is ISyndicateFactory {

    /// @notice Address of syndicate implementation that is cloned on each syndicate deployment
    address public syndicateImplementation;

    /// @param _syndicateImpl Address of syndicate implementation that is cloned on each syndicate deployment
    constructor(address _syndicateImpl) {
        syndicateImplementation = _syndicateImpl;
    }

    /// @inheritdoc ISyndicateFactory
    function deploySyndicate(
        address _contractOwner,
        uint256 _priorityStakingEndBlock,
        address[] calldata _priorityStakers,
        bytes[] calldata _blsPubKeysForSyndicateKnots
    ) public override returns (address) {
        // Use CREATE2 to deploy the new instance of the syndicate
        address newInstance = Clones.cloneDeterministic(
            syndicateImplementation,
            calculateDeploymentSalt(msg.sender, _contractOwner, _blsPubKeysForSyndicateKnots.length)
        );

        // Initialize the new syndicate instance with the params from the deployer
        ISyndicateInit(newInstance).initialize(
            _contractOwner,
            _priorityStakingEndBlock,
            _priorityStakers,
            _blsPubKeysForSyndicateKnots
        );

        // Off chain logging of all deployed instances from this factory
        emit SyndicateDeployed(newInstance);

        return newInstance;
    }

    /// @inheritdoc ISyndicateFactory
    function calculateSyndicateDeploymentAddress(
        address _deployer,
        address _contractOwner,
        uint256 _numberOfInitialKnots
    ) external override view returns (address) {
        bytes32 salt = calculateDeploymentSalt(_deployer, _contractOwner, _numberOfInitialKnots);
        return Clones.predictDeterministicAddress(syndicateImplementation, salt);
    }

    /// @inheritdoc ISyndicateFactory
    function calculateDeploymentSalt(
        address _deployer,
        address _contractOwner,
        uint256 _numberOfInitialKnots
    ) public override pure returns (bytes32) {
        return keccak256(abi.encode(_deployer, _contractOwner, _numberOfInitialKnots));
    }
}