// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IBrandNFT {
    function toLowerCase(string memory _base) external pure returns (string memory);
    function lowercaseBrandTickerToTokenId(string memory _ticker) external returns (uint256);
}