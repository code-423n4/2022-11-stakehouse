pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import { Syndicate } from "../../syndicate/Syndicate.sol";
import { MockStakeHouseUniverse } from "../stakehouse/MockStakeHouseUniverse.sol";
import { MockSlotRegistry } from "../stakehouse/MockSlotRegistry.sol";
import { IStakeHouseUniverse } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/IStakeHouseUniverse.sol";
import { ISlotSettlementRegistry } from "@blockswaplab/stakehouse-contract-interfaces/contracts/interfaces/ISlotSettlementRegistry.sol";
import { IFactoryDependencyInjector } from "../interfaces/IFactoryDependencyInjector.sol";

/// @dev Use the mock contract for testing the syndicate by overriding API addresses
contract SyndicateMock is Syndicate {

    // Mock universe and slot registry allowing testing of syndicate without full stakehouse contract suite
    address public uni;
    address public slotReg;

    function initialize(
        address _contractOwner,
        uint256 _priorityStakingEndBlock,
        address[] memory _priorityStakers,
        bytes[] memory _blsPubKeysForSyndicateKnots
    ) external override initializer {
        // Create the mock universe and slot registry
        uni = IFactoryDependencyInjector(_contractOwner).uni();
        slotReg = IFactoryDependencyInjector(_contractOwner).slot();

        // then initialize the underlying syndicate contract
        _initialize(
            _contractOwner,
            _priorityStakingEndBlock,
            _priorityStakers,
            _blsPubKeysForSyndicateKnots
        );
    }

    /// ----------------------
    /// Override Solidity API
    /// ----------------------

    // Proxy into mock Stakehouse contracts

    function getStakeHouseUniverse() internal view override returns (IStakeHouseUniverse universe) {
        return IStakeHouseUniverse(uni);
    }

    function getSlotRegistry() internal view override returns (ISlotSettlementRegistry slotSettlementRegistry) {
        return ISlotSettlementRegistry(slotReg);
    }
}