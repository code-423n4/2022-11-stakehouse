// SPDX-License-Identifier: MIT

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity 0.8.13;

contract MockSavETHRegistry {

    IERC20 public dETHToken;
    function setDETHToken(IERC20 _dETH) external {
        dETHToken = _dETH;
    }

    uint256 public indexPointer;
    mapping(uint256 => address) public indexIdToOwner;

    // Mock the creation of an isolated basket of dETH assets
    function createIndex(address _owner) external returns (uint256) {
        indexIdToOwner[++indexPointer] = _owner;
        return indexPointer;
    }

    // Direct manipulation of index balances - in real implementation dETH always starts part of an isolated index
    mapping(uint256 => mapping(bytes => uint256)) public balInIndex;
    function setBalInIndex(uint256 _indexId, bytes calldata _blsKey, uint256 _bal) external {
        balInIndex[_indexId][_blsKey] = _bal;
    }

    function knotDETHBalanceInIndex(uint256 _indexId, bytes calldata _blsKey) external view returns (uint256) {
        return balInIndex[_indexId][_blsKey] > 0 ? balInIndex[_indexId][_blsKey] : 24 ether ;
    }

    function addKnotToOpenIndexAndWithdraw(
        address _stakeHouse,
        bytes calldata _blsPubKey,
        address _receipient
    ) external {
        // No mock implementation at the moment
    }

    function addKnotToOpenIndex(
        address _stakeHouse,
        bytes calldata _blsPubKey,
        address _receipient
    ) external {
        // No mock implementation at the moment
    }

    function withdraw(
        address _recipient,
        uint128 _amount
    ) external {
        dETHToken.transfer(_recipient, savETHToDETH(_amount));
    }

    function savETHToDETH(uint256 _amount) public pure returns (uint256) {
        // Currently assumes 1:1
        return _amount;
    }

    function dETHToSavETH(uint256 _amount) public pure returns (uint256) {
        // Currently assumes 1:1
        return _amount;
    }
}