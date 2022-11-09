pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import "forge-std/console.sol";
import { TestUtils } from "../utils/TestUtils.sol";

import { GiantSavETHVaultPool } from "../../contracts/liquid-staking/GiantSavETHVaultPool.sol";
import { GiantMevAndFeesPool } from "../../contracts/liquid-staking/GiantMevAndFeesPool.sol";
import { LPToken } from "../../contracts/liquid-staking/LPToken.sol";
import { MockSlotRegistry } from "../../contracts/testing/stakehouse/MockSlotRegistry.sol";
import { MockSavETHVault } from "../../contracts/testing/liquid-staking/MockSavETHVault.sol";
import { MockGiantSavETHVaultPool } from "../../contracts/testing/liquid-staking/MockGiantSavETHVaultPool.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GiantPoolTests is TestUtils {

    MockGiantSavETHVaultPool public giantSavETHPool;
    GiantMevAndFeesPool public giantFeesAndMevPool;

    function setUp() public {
        vm.startPrank(accountFive); // this will mean it gets dETH initial supply
        factory = createMockLSDNFactory();
        vm.stopPrank();

        // Deploy 1 network
        manager = deployNewLiquidStakingNetwork(
            factory,
            admin,
            true,
            "LSDN"
        );

        savETHVault = MockSavETHVault(address(manager.savETHVault()));

        giantSavETHPool = new MockGiantSavETHVaultPool(factory, savETHVault.dETHToken());
        giantFeesAndMevPool = new GiantMevAndFeesPool(factory);
    }

    function testETHSuppliedFromGiantPoolCanBeUsedInFactoryDeployedLSDN() public {
        // Set up users and ETH
        address nodeRunner = accountOne; vm.deal(nodeRunner, 12 ether);
        address feesAndMevUserOne = accountTwo; vm.deal(feesAndMevUserOne, 4 ether);
        address savETHUser = accountThree; vm.deal(savETHUser, 24 ether);

        // Register BLS key
        registerSingleBLSPubKey(nodeRunner, blsPubKeyOne, accountFour);

        // Deposit ETH into giant savETH
        vm.prank(savETHUser);
        giantSavETHPool.depositETH{value: 24 ether}(24 ether);
        assertEq(giantSavETHPool.lpTokenETH().balanceOf(savETHUser), 24 ether);
        assertEq(address(giantSavETHPool).balance, 24 ether);

        // Deploy ETH from giant LP into savETH pool of LSDN instance
        bytes[][] memory blsKeysForVaults = new bytes[][](1);
        blsKeysForVaults[0] = getBytesArrayFromBytes(blsPubKeyOne);

        uint256[][] memory stakeAmountsForVaults = new uint256[][](1);
        stakeAmountsForVaults[0] = getUint256ArrayFromValues(24 ether);

        giantSavETHPool.batchDepositETHForStaking(
            getAddressArrayFromValues(address(manager.savETHVault())),
            getUint256ArrayFromValues(24 ether),
            blsKeysForVaults,
            stakeAmountsForVaults
        );
        assertEq(address(manager.savETHVault()).balance, 24 ether);

        // Deposit ETH into giant fees and mev
        vm.startPrank(feesAndMevUserOne);
        //manager.stakingFundsVault().depositETHForStaking{value: 4 ether}(blsPubKeyOne, 4 ether);
        giantFeesAndMevPool.depositETH{value: 4 ether}(4 ether);
        vm.stopPrank();

        assertEq(address(giantFeesAndMevPool).balance, 4 ether);
        stakeAmountsForVaults[0] = getUint256ArrayFromValues(4 ether);
        giantFeesAndMevPool.batchDepositETHForStaking(
            getAddressArrayFromValues(address(manager.stakingFundsVault())),
            getUint256ArrayFromValues(4 ether),
            blsKeysForVaults,
            stakeAmountsForVaults
        );

        // Ensure we can stake and mint derivatives
        stakeAndMintDerivativesSingleKey(blsPubKeyOne);

        IERC20 dETHToken = savETHVault.dETHToken();

        vm.startPrank(accountFive);
        dETHToken.transfer(address(savETHVault.saveETHRegistry()), 24 ether);
        vm.stopPrank();

        LPToken[] memory tokens = new LPToken[](1);
        tokens[0] = savETHVault.lpTokenForKnot(blsPubKeyOne);

        LPToken[][] memory allTokens = new LPToken[][](1);
        allTokens[0] = tokens;

        stakeAmountsForVaults[0] = getUint256ArrayFromValues(24 ether);

        // User will not have any dETH to start
        assertEq(dETHToken.balanceOf(savETHUser), 0);

        // Warp ahead
        vm.warp(block.timestamp + 2 days);

        vm.startPrank(savETHUser);
        giantSavETHPool.withdrawDETH(
            getAddressArrayFromValues(address(manager.savETHVault())),
            allTokens,
            stakeAmountsForVaults
        );
        vm.stopPrank();

        assertEq(dETHToken.balanceOf(savETHUser), 24 ether);
    }

}