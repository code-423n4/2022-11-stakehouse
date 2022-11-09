pragma solidity ^0.8.13;

// SPDX-License-Identifier: MIT

import "forge-std/console.sol";

import { TestUtils } from "../utils/TestUtils.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MockSlotRegistry } from "../../contracts/testing/stakehouse/MockSlotRegistry.sol";
import { MockSavETHRegistry } from "../../contracts/testing/stakehouse/MockSavETHRegistry.sol";

contract LiquidStakingManagerTests is TestUtils {

    function setUp() public {
        vm.startPrank(accountFive); // this will mean it gets dETH initial supply
        factory = createMockLSDNFactory();
        vm.stopPrank();

        // Deploy 1 network and get default dependencies
        manager = deployNewLiquidStakingNetwork(
            factory,
            admin,
            true,
            "LSDN"
        );

        savETHVault = getSavETHVaultFromManager(manager);
        stakingFundsVault = getStakingFundsVaultFromManager(manager);

        // make 'admin' the 'DAO'
        vm.prank(address(factory));
        manager.updateDAOAddress(admin);
    }

    // todo - test for multiple knots
    function testDAOCanCoordinateRageQuitOfOnlyKnotInNetwork() public {
        // Set up users and ETH
        address nodeRunner = accountOne; vm.deal(nodeRunner, 4 ether);
        address feesAndMevUser = accountTwo; vm.deal(feesAndMevUser, 4 ether);
        address savETHUser = accountThree; vm.deal(savETHUser, 24 ether);

        // Do everything from funding a validator within default LSDN to minting derivatives
        depositStakeAndMintDerivativesForDefaultNetwork(
            nodeRunner,
            feesAndMevUser,
            savETHUser,
            blsPubKeyFour
        );

        // Send syndicate some EIP1559 rewards
        uint256 eip1559Tips = 0.6743 ether;
        sendEIP1559RewardsToSyndicateAtAddress(eip1559Tips, manager.syndicate());

        // Claim dETH as savETH user
        IERC20 dETHToken = savETHVault.dETHToken();
        vm.startPrank(accountFive);
        dETHToken.transfer(address(savETHVault.saveETHRegistry()), 24 ether * 2);
        vm.stopPrank();

        vm.startPrank(savETHUser);
        savETHVault.burnLPTokensByBLS(getBytesArrayFromBytes(blsPubKeyFour), getUint256ArrayFromValues(24 ether));
        vm.stopPrank();
        assertEq(dETHToken.balanceOf(savETHUser), 24 ether);

        // Check there are some rewards to claim by staking funds vault
        assertEq(
            manager.stakingFundsVault().previewAccumulatedETH(feesAndMevUser, stakingFundsVault.lpTokenForKnot(blsPubKeyFour)),
            (eip1559Tips / 2) - 1
        );

        // now de-register knot from syndicate to send sETH back to smart wallet
        IERC20 sETH = IERC20(MockSlotRegistry(factory.slot()).stakeHouseShareTokens(manager.stakehouse()));
        uint256 sETHBalanceBefore = sETH.balanceOf(manager.smartWalletOfNodeRunner(nodeRunner));
        vm.startPrank(admin);
        manager.deRegisterKnotFromSyndicate(getBytesArrayFromBytes(blsPubKeyFour));
        manager.restoreFreeFloatingSharesToSmartWalletForRageQuit(
            manager.smartWalletOfNodeRunner(nodeRunner),
            getBytesArrayFromBytes(blsPubKeyFour),
            getUint256ArrayFromValues(12 ether)
        );
        vm.stopPrank();

        assertEq(
            sETH.balanceOf(manager.smartWalletOfNodeRunner(nodeRunner)) - sETHBalanceBefore,
            12 ether
        );

        // As long as the smart wallet has free floating and collateralized SLOT + dETH isolated, then we assume rage quit will work at stakehouse level
        // We execute an arbitrary transaction here to confirm `executeAsSmartWallet` is working as if rage quit took place
        assertEq(savETHVault.saveETHRegistry().knotDETHBalanceInIndex(1, blsPubKeyFour), 24 ether);
        savETHVault.saveETHRegistry().setBalInIndex(1, blsPubKeyFour, 1);
        vm.startPrank(admin);
        manager.executeAsSmartWallet(
            nodeRunner,
            address(savETHVault.saveETHRegistry()),
            abi.encodeWithSelector(
                MockSavETHRegistry.setBalInIndex.selector,
                1,
                blsPubKeyFour,
                1
            ),
            0
        );
        vm.stopPrank();
        assertEq(savETHVault.saveETHRegistry().knotDETHBalanceInIndex(1, blsPubKeyFour), 1);

        vm.warp(block.timestamp + 3 hours);

        // Now, as Staking funds vault LP holder you should be able to claim rewards accrued up to point of pulling the plug
        vm.startPrank(feesAndMevUser);
        stakingFundsVault.claimRewards(feesAndMevUser, getBytesArrayFromBytes(blsPubKeyFour));
        vm.stopPrank();
        assertEq(feesAndMevUser.balance, (eip1559Tips / 2) - 1);

        // As collateralized SLOT holder for BLS pub key four, you should be able to claim rewards accrued up to point of pulling the plug
        vm.startPrank(nodeRunner);
        manager.claimRewardsAsNodeRunner(nodeRunner, getBytesArrayFromBytes(blsPubKeyFour));
        vm.stopPrank();
        assertEq(nodeRunner.balance, (eip1559Tips / 2));
    }
}