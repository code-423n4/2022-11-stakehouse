pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { ILPTokenInit } from "../interfaces/ILPTokenInit.sol";

/// @notice Contract for deploying a new LP token
contract LPTokenFactory {

    /// @notice Emitted when a new LP token instance is deployed
    event LPTokenDeployed(address indexed factoryCloneToken);

    /// @notice Address of LP token implementation that is cloned on each LP token
    address public lpTokenImplementation;

    /// @param _lpTokenImplementation Address of LP token implementation that is cloned on each LP token deployment
    constructor(address _lpTokenImplementation) {
        require(_lpTokenImplementation != address(0), "Address cannot be zero");

        lpTokenImplementation = _lpTokenImplementation;
    }

    /// @notice Deploys a new LP token
    /// @param _tokenSymbol Symbol of the LP token to be deployed
    /// @param _tokenName Name of the LP token to be deployed
    function deployLPToken(
        address _deployer,
        address _transferHookProcessor,
        string calldata _tokenSymbol,
        string calldata _tokenName
    ) external returns (address) {
        require(address(_deployer) != address(0), "Zero address");
        require(bytes(_tokenSymbol).length != 0, "Symbol cannot be zero");
        require(bytes(_tokenName).length != 0, "Name cannot be zero");

        address newInstance = Clones.clone(lpTokenImplementation);
        ILPTokenInit(newInstance).init(
            _deployer,
            _transferHookProcessor,
            _tokenSymbol,
            _tokenName
        );

        emit LPTokenDeployed(newInstance);

        return newInstance;
    }
}