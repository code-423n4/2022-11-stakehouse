// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { console } from "forge-std/console.sol";

import { MockERC20 } from "../../contracts/testing/MockERC20.sol";
import { SyndicateMock } from "../../contracts/testing/syndicate/SyndicateMock.sol";

import { MockAccountManager } from "../../contracts/testing/stakehouse/MockAccountManager.sol";
import { MockTransactionRouter } from "../../contracts/testing/stakehouse/MockTransactionRouter.sol";
import { MockSlotRegistry } from "../../contracts/testing/stakehouse/MockSlotRegistry.sol";
import { MockStakeHouseUniverse } from "../../contracts/testing/stakehouse/MockStakeHouseUniverse.sol";

import { SyndicateFactoryMock } from "../../contracts/testing/syndicate/SyndicateFactoryMock.sol";
import {
    KnotIsFullyStakedWithFreeFloatingSlotTokens,
    KnotIsAlreadyRegistered
} from "../../contracts/syndicate/SyndicateErrors.sol";

import { TestUtils } from "../utils/TestUtils.sol";

contract SyndicateTest is TestUtils {

    MockERC20 public sETH;

    SyndicateFactoryMock public syndicateFactory;

    SyndicateMock public syndicate;

    function blsPubKeyOneAsArray() public view returns (bytes[] memory) {
        bytes[] memory keys = new bytes[](1);
        keys[0] = blsPubKeyOne;
        return keys;
    }

    function sendEIP1559RewardsToSyndicate(uint256 eip1559Reward) public {
        (bool success, ) = address(syndicate).call{value: eip1559Reward}("");
        assertEq(success, true);
        assertEq(address(syndicate).balance, eip1559Reward);
    }

    function setUp() public {
        // Deploy an sETH token for an arbitrary stakehouse
        sETH = new MockERC20("sETH", "sETH", accountOne);

        // Deploy the syndicate but no priority stakers are required
        address[] memory priorityStakers = new address[](0);

        // Create and inject mock stakehouse dependencies
        address accountMan = address(new MockAccountManager());
        address txRouter = address(new MockTransactionRouter());
        address uni = address(new MockStakeHouseUniverse());
        address slot = address(new MockSlotRegistry());
        syndicateFactory = new SyndicateFactoryMock(
            accountMan,
            txRouter,
            uni,
            slot
        );

        address payable _syndicate = payable(syndicateFactory.deployMockSyndicate(
            admin,
            0, // No priority staking block
            priorityStakers,
            blsPubKeyOneAsArray()
        ));

        syndicate = SyndicateMock(_syndicate);

        // Config mock stakehouse contracts
        MockSlotRegistry(syndicate.slotReg()).setShareTokenForHouse(houseOne, address(sETH));

        MockStakeHouseUniverse(syndicate.uni()).setAssociatedHouseForKnot(blsPubKeyOne, houseOne);
        MockStakeHouseUniverse(syndicate.uni()).setAssociatedHouseForKnot(blsPubKeyTwo, houseOne);
        MockStakeHouseUniverse(syndicate.uni()).setAssociatedHouseForKnot(blsPubKeyThree, houseOne);

        MockSlotRegistry(syndicate.slotReg()).setNumberOfCollateralisedSlotOwnersForKnot(blsPubKeyOne, 1);
        MockSlotRegistry(syndicate.slotReg()).setNumberOfCollateralisedSlotOwnersForKnot(blsPubKeyTwo, 1);
        MockSlotRegistry(syndicate.slotReg()).setNumberOfCollateralisedSlotOwnersForKnot(blsPubKeyThree, 1);

        MockSlotRegistry(syndicate.slotReg()).setCollateralisedOwnerAtIndex(blsPubKeyOne, 0, accountTwo);
        MockSlotRegistry(syndicate.slotReg()).setCollateralisedOwnerAtIndex(blsPubKeyTwo, 0, accountFour);
        MockSlotRegistry(syndicate.slotReg()).setCollateralisedOwnerAtIndex(blsPubKeyThree, 0, accountFive);

        MockSlotRegistry(syndicate.slotReg()).setUserCollateralisedSLOTBalanceForKnot(houseOne, accountTwo, blsPubKeyOne, 4 ether);
        MockSlotRegistry(syndicate.slotReg()).setUserCollateralisedSLOTBalanceForKnot(houseOne, accountFour, blsPubKeyTwo, 4 ether);
        MockSlotRegistry(syndicate.slotReg()).setUserCollateralisedSLOTBalanceForKnot(houseOne, accountFive, blsPubKeyThree, 4 ether);
    }

    function testSupply() public {
        assertEq(sETH.totalSupply(), 125_000 * 10 ** 18);
        assertEq(sETH.balanceOf(accountOne), 125_000 * 10 ** 18);
    }

    function testThreeKnotsMultipleStakers() public {
        // Set up test - distribute sETH and register additional knot to syndicate
        vm.prank(admin);
        syndicate.registerKnotsToSyndicate(getBytesArrayFromBytes(blsPubKeyTwo));

        vm.startPrank(accountOne);
        sETH.transfer(accountThree, 500 ether);
        sETH.transfer(accountFive, 500 ether);
        vm.stopPrank();

        // for bls pub key one we will have 2 stakers staking 50% each
        uint256 stakingAmount = 6 ether;
        uint256[] memory sETHAmounts = new uint256[](1);
        sETHAmounts[0] = stakingAmount;

        vm.startPrank(accountOne);
        sETH.approve(address(syndicate), stakingAmount);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);
        vm.stopPrank();

        vm.startPrank(accountThree);
        sETH.approve(address(syndicate), stakingAmount);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountThree);
        vm.stopPrank();

        sETHAmounts[0] = 12 ether;
        vm.startPrank(accountFive);
        sETH.approve(address(syndicate), sETHAmounts[0]);
        syndicate.stake(getBytesArrayFromBytes(blsPubKeyTwo), sETHAmounts, accountFive);
        vm.stopPrank();

        // send some rewards
        uint256 eipRewards = 0.0943 ether;
        sendEIP1559RewardsToSyndicate(eipRewards);

        vm.prank(accountOne);
        vm.expectRevert(KnotIsFullyStakedWithFreeFloatingSlotTokens.selector);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);

        // Check syndicate state
        assertEq(syndicate.totalETHReceived(), eipRewards);

        // claim
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = 0;

        assertEq(accountTwo.balance, 0);
        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, getBytesArrayFromBytes(blsPubKeyOne));
        assertEq(accountTwo.balance, eipRewards / 4);

        assertEq(accountFour.balance, 0);
        vm.prank(accountFour);
        syndicate.claimAsCollateralizedSLOTOwner(accountFour, getBytesArrayFromBytes(blsPubKeyTwo));
        assertEq(accountFour.balance, eipRewards / 4);

        assertEq(accountFive.balance, 0);
        vm.prank(accountFive);
        syndicate.claimAsStaker(accountFive, getBytesArrayFromBytes(blsPubKeyTwo));
        assertEq(accountFive.balance, (eipRewards / 4) - 1);

        assertEq(accountOne.balance, 0);
        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, getBytesArrayFromBytes(blsPubKeyOne));
        assertEq(accountOne.balance, (eipRewards / 8) - 1);

        assertEq(accountThree.balance, 0);
        vm.prank(accountThree);
        syndicate.claimAsStaker(accountThree, getBytesArrayFromBytes(blsPubKeyOne));
        assertEq(accountThree.balance, (eipRewards / 8) - 1);

        // Check syndicate state
        assertEq(syndicate.totalETHReceived(), eipRewards);
        assertEq(address(syndicate).balance, 3); // Dust is left behind due to Solidity calc issues

        vm.prank(admin);
        vm.expectRevert(KnotIsAlreadyRegistered.selector);
        syndicate.registerKnotsToSyndicate(getBytesArrayFromBytes(blsPubKeyOne));

        vm.prank(admin);
        syndicate.registerKnotsToSyndicate(getBytesArrayFromBytes(blsPubKeyThree));
    }

    function testOneKnotWithMultipleFreeFloatingStakers() public {
        // account two is the collateralized owner for bls pub key one. Everyone else can be free floating staker but they need sETH
        vm.startPrank(accountOne);
        sETH.transfer(accountThree, 500 ether);
        sETH.transfer(accountFour, 500 ether);
        vm.stopPrank();

        // Stake free floating slot
        uint256 stakeAmount = 4 ether;
        uint256[] memory sETHAmounts = new uint256[](1);
        sETHAmounts[0] = stakeAmount;

        vm.startPrank(accountOne);
        sETH.approve(address(syndicate), stakeAmount);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);
        vm.stopPrank();

        vm.startPrank(accountThree);
        sETH.approve(address(syndicate), stakeAmount);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountThree);
        vm.stopPrank();

        vm.startPrank(accountFour);
        sETH.approve(address(syndicate), stakeAmount);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountFour);
        vm.stopPrank();

        // send some eip rewards to syndicate
        uint256 eipRewards = 0.54 ether;
        sendEIP1559RewardsToSyndicate(eipRewards);

        // Claim as free floating
        assertEq(accountOne.balance, 0);
        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());
        assertEq(accountOne.balance, 0.09 ether);

        assertEq(accountThree.balance, 0);
        vm.prank(accountThree);
        syndicate.claimAsStaker(accountThree, blsPubKeyOneAsArray());
        assertEq(accountThree.balance, 0.09 ether);

        assertEq(accountFour.balance, 0);
        vm.prank(accountFour);
        syndicate.claimAsStaker(accountFour, blsPubKeyOneAsArray());
        assertEq(accountFour.balance, 0.09 ether);

        // Now as the collateralized SLOT owner has not claimed, 0.27 out of 0.54 should still be with syndicate
        assertEq(address(syndicate).balance, 0.27 ether);

        // Collateralized owner claims
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = 0;
        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());
        assertEq(address(syndicate).balance, 0);
        assertEq(accountTwo.balance, 0.27 ether);

        // nothing should happen by claiming again
        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());
        assertEq(address(syndicate).balance, 0);
        assertEq(accountTwo.balance, 0.27 ether);

        assertEq(accountOne.balance, 0.09 ether);
        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());
        assertEq(accountOne.balance, 0.09 ether);

        assertEq(accountThree.balance, 0.09 ether);
        vm.prank(accountThree);
        syndicate.claimAsStaker(accountThree, blsPubKeyOneAsArray());
        assertEq(accountThree.balance, 0.09 ether);

        assertEq(accountFour.balance, 0.09 ether);
        vm.prank(accountFour);
        syndicate.claimAsStaker(accountFour, blsPubKeyOneAsArray());
        assertEq(accountFour.balance, 0.09 ether);
    }

    function testExpansionOfKnotSet() public {
        // Testing scenario where:
        // - syn is deployed
        // - it accrues ETH
        // - no one claims
        // - new knots are added to syn
        // - old ones claim successfully
        // - new ones have nothing to claim
        // - when ETH comes in again, then the full set can claim that additional ETH

        // Start test
        // Check that one knot is registered
        assertEq(syndicate.numberOfRegisteredKnots(), 1);
        assertEq(syndicate.isKnotRegistered(blsPubKeyOne), true);

        // Distribute some rewards, stake, no one claims and check claim amounts
        uint256 eip1559Reward = 0.165 ether;
        sendEIP1559RewardsToSyndicate(eip1559Reward);

        uint256 collateralizedIndex = 0;
        uint256[] memory collateralizedIndexes = new uint256[](1);
        collateralizedIndexes[0] = collateralizedIndex;

        uint256 stakeAmount = 12 ether;
        uint256[] memory sETHAmounts = new uint256[](1);
        sETHAmounts[0] = stakeAmount;

        vm.startPrank(accountOne);
        sETH.approve(address(syndicate), 12 ether);
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);
        vm.stopPrank();

        // Without claiming ensure free floating staker and collateralized owners can claim correct amount of rewards
        assertEq(
            syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne),
            eip1559Reward / 2
        );

        assertEq(
            syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountTwo, blsPubKeyOne),
            eip1559Reward / 2
        );

        assertEq(syndicate.totalETHReceived(), eip1559Reward);

        // Expand KNOT set
        vm.prank(admin);
        syndicate.registerKnotsToSyndicate(getBytesArrayFromBytes(blsPubKeyTwo));

        assertEq(syndicate.numberOfRegisteredKnots(), 2);
        assertEq(syndicate.isKnotRegistered(blsPubKeyOne), true);
        assertEq(syndicate.isKnotRegistered(blsPubKeyTwo), true);

        // Check claim amount for previous stakers is still correct
        assertEq(syndicate.totalClaimed(), 0);
        assertEq(address(syndicate).balance, eip1559Reward);
        assertEq(syndicate.totalETHReceived(), eip1559Reward);
        assertEq(syndicate.accumulatedETHPerFreeFloatingShare(), 6875000000000000000000);
        assertEq(syndicate.calculateNewAccumulatedETHPerFreeFloatingShare(), 0);
        assertEq(syndicate.sETHTotalStakeForKnot(blsPubKeyOne), stakeAmount);
        assertEq(syndicate.sETHStakedBalanceForKnot(blsPubKeyOne, accountOne), stakeAmount);
        assertEq(
            syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne),
            eip1559Reward / 2
        );

        assertEq(
            syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountTwo, blsPubKeyOne),
            eip1559Reward / 2
        );

        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());
        assertEq(accountOne.balance, eip1559Reward / 2);
        assertEq(syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne), 0);
        assertEq(
            syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountTwo, blsPubKeyOne),
            eip1559Reward / 2
        );

        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());
        assertEq(syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountTwo, blsPubKeyOne), 0);
        assertEq(accountTwo.balance, eip1559Reward / 2);
        assertEq(address(syndicate).balance, 0);

        // introduce a third staker for free floating
        vm.prank(accountOne);
        sETH.transfer(accountThree, stakeAmount);

        vm.startPrank(accountThree);
        sETHAmounts[0] = stakeAmount;
        sETH.approve(address(syndicate), stakeAmount);
        syndicate.stake(
            getBytesArrayFromBytes(blsPubKeyTwo),
            sETHAmounts,
            accountThree
        );
        vm.stopPrank();

        // send some more rewards again
        sendEIP1559RewardsToSyndicate(eip1559Reward);

        assertEq(syndicate.totalClaimed(), eip1559Reward);
        assertEq(syndicate.totalFreeFloatingShares(), stakeAmount * 2);
        assertEq(sETH.balanceOf(address(syndicate)), stakeAmount * 2);

        uint256 ethPerKnot = eip1559Reward / 2;
        uint256 ethPerFreeFloatingOrCollateralized = ethPerKnot;
        uint256 unclaimedFreeFloatingAccountOne = syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne);
        uint256 unclaimedFreeFloatingAccountThree = syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountThree, blsPubKeyTwo);
        assertEq(
            unclaimedFreeFloatingAccountOne + unclaimedFreeFloatingAccountThree,
            ethPerFreeFloatingOrCollateralized
        );

        uint256 accountOneBalBeforeClaim = accountOne.balance;
        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());
        assertEq(accountOne.balance - accountOneBalBeforeClaim, unclaimedFreeFloatingAccountOne);

        uint256 accountThreeBalBeforeClaim = accountThree.balance;
        vm.prank(accountThree);
        syndicate.claimAsStaker(accountThree, getBytesArrayFromBytes(blsPubKeyTwo));
        assertEq(accountThree.balance - accountThreeBalBeforeClaim, unclaimedFreeFloatingAccountThree);

        assertEq(syndicate.getUnprocessedETHForAllCollateralizedSlot(), 0);
        assertEq(syndicate.getUnprocessedETHForAllFreeFloatingSlot(), 0);

        uint256 unclaimedCollateralizedAccountTwo = syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountTwo, blsPubKeyOne);
        uint256 unclaimedCollateralizedAccountFour = syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(accountFour, blsPubKeyTwo);
        assertEq(
            unclaimedCollateralizedAccountTwo + unclaimedCollateralizedAccountFour,
            ethPerFreeFloatingOrCollateralized
        );

        uint256 accountTwoBalBefore = accountTwo.balance;
        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());
        assertEq(accountTwo.balance - accountTwoBalBefore, unclaimedCollateralizedAccountTwo);

        vm.prank(accountFour);
        syndicate.claimAsCollateralizedSLOTOwner(accountFour, getBytesArrayFromBytes(blsPubKeyTwo));
        assertEq(accountFour.balance, unclaimedCollateralizedAccountFour);

        assertEq(address(syndicate).balance, 0);
    }

    function testClaimAsCollateralizedSlotOwner() public {
        uint256 eip1559Reward = 0.165 ether;
        sendEIP1559RewardsToSyndicate(eip1559Reward);

        uint256 collateralizedIndex = 0;
        uint256[] memory collateralizedIndexes = new uint256[](1);
        collateralizedIndexes[0] = collateralizedIndex;

        assertEq(accountTwo.balance, 0);

        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());

        assertEq(accountTwo.balance, eip1559Reward / 2);
        assertEq(address(syndicate).balance, eip1559Reward / 2);
    }

    function testStakeFreeFloatingReceiveETHAndThenClaim() public {
        uint256 stakeAmount = 12 ether;
        uint256[] memory sETHAmounts = new uint256[](1);
        sETHAmounts[0] = stakeAmount;

        // Assume account one as message sender
        vm.startPrank(accountOne);

        // issue allowance to stake
        sETH.approve(address(syndicate), sETHAmounts[0]);

        // stake
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);

        // End impersonation
        vm.stopPrank();

        assertEq(sETH.balanceOf(address(syndicate)), stakeAmount);
        assertEq(syndicate.totalFreeFloatingShares(), stakeAmount);
        assertEq(syndicate.sETHTotalStakeForKnot(blsPubKeyOne), stakeAmount);
        assertEq(syndicate.sETHStakedBalanceForKnot(blsPubKeyOne, accountOne), stakeAmount);
        assertEq(syndicate.sETHUserClaimForKnot(blsPubKeyOne, accountOne), 0);
        assertEq(syndicate.accumulatedETHPerFreeFloatingShare(), 0);
        assertEq(syndicate.lastSeenETHPerFreeFloating(), 0);
        //assertEq(syndicate.lastSeenETHPerCollateralizedSlot(), 0);

        uint256 eip1559Reward = 0.04 ether;
        sendEIP1559RewardsToSyndicate(eip1559Reward);

        // Preview amount of unclaimed ETH before updating contract state
        assertEq(
            syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne),
            0.02 ether - 1
        );

        syndicate.updateAccruedETHPerShares();

        assertEq(syndicate.lastSeenETHPerFreeFloating(), eip1559Reward / 2);
        //assertEq(syndicate.lastSeenETHPerCollateralizedSlot(), eip1559Reward / 2);
        assertEq(syndicate.totalETHReceived(), eip1559Reward);
        assertEq(syndicate.calculateETHForFreeFloatingOrCollateralizedHolders(), eip1559Reward / 2);
        assertEq(syndicate.accumulatedETHPerFreeFloatingShare(), ((eip1559Reward / 2) * 1e24) / stakeAmount);
        assertEq(syndicate.sETHUserClaimForKnot(blsPubKeyOne, accountOne), 0);

        assertEq(address(syndicate).balance, 0.04 ether);

        // Preview amount of unclaimed ETH post updating contract state
        assertEq(
            syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne),
                0.02 ether - 1
        );

        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());

        // Contract balance should have reduced
        // Solidity precision loss of 1 wei
        assertEq(address(syndicate).balance, 0.02 ether + 1);

        // Unclaimed ETH amount should now be zero
        assertEq(
            syndicate.previewUnclaimedETHAsFreeFloatingStaker(accountOne, blsPubKeyOne),
            0
        );

        // user ETH balance should now be 0.02 ether minus 1 due to precision loss
        assertEq(accountOne.balance, 0.02 ether - 1);

        // try to claim again and fail
        vm.prank(accountOne);
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());
        assertEq(address(syndicate).balance, 0.02 ether + 1);

        vm.prank(accountOne);
        syndicate.unstake(accountOne, accountOne, blsPubKeyOneAsArray(), sETHAmounts);
        assertEq(address(syndicate).balance, 0.02 ether + 1);

        vm.startPrank(accountOne);

        // issue allowance to stake
        sETH.approve(address(syndicate), sETHAmounts[0]);

        uint256 expectedDebt = (syndicate.accumulatedETHPerFreeFloatingShare() * stakeAmount) / syndicate.PRECISION();

        // stake
        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);

        // Check user was assigned the correct debt on re-staking so they cannot double claim
        assertEq(syndicate.sETHUserClaimForKnot(blsPubKeyOne, accountOne), expectedDebt);

        // try to claim again and fail
        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());

        // End impersonation
        vm.stopPrank();

        assertEq(address(syndicate).balance, 0.02 ether + 1);
    }

    // TODO - fuzz claiming
    function testBothCollateralizedAndSlotClaim() public {
        uint256 eip1559Reward = 0.165 ether;
        sendEIP1559RewardsToSyndicate(eip1559Reward);

        uint256 collateralizedIndex = 0;
        uint256[] memory collateralizedIndexes = new uint256[](1);
        collateralizedIndexes[0] = collateralizedIndex;

        // set up collateralized knot
        MockSlotRegistry(syndicate.slotReg()).setCollateralisedOwnerAtIndex(blsPubKeyOne, collateralizedIndex, accountTwo);
        MockSlotRegistry(syndicate.slotReg()).setUserCollateralisedSLOTBalanceForKnot(houseOne, accountTwo, blsPubKeyOne, 4 ether);

        assertEq(accountTwo.balance, 0);
        assertEq(
            syndicate.previewUnclaimedETHAsCollateralizedSlotOwner(
                accountTwo,
                blsPubKeyOne
            ),
            eip1559Reward / 2
        );

        vm.prank(accountTwo);
        syndicate.claimAsCollateralizedSLOTOwner(accountTwo, blsPubKeyOneAsArray());

        assertEq(accountTwo.balance, eip1559Reward / 2);
        assertEq(address(syndicate).balance, eip1559Reward / 2);

        // now let free floating guy come in and stake sETH
        vm.startPrank(accountOne);

        uint256 stakeAmount = 12 ether;
        uint256[] memory sETHAmounts = new uint256[](1);
        sETHAmounts[0] = stakeAmount;

        sETH.approve(address(syndicate), stakeAmount);

        syndicate.stake(blsPubKeyOneAsArray(), sETHAmounts, accountOne);

        assertEq(accountOne.balance, 0);
        assertEq(address(syndicate).balance, eip1559Reward / 2);

        syndicate.claimAsStaker(accountOne, blsPubKeyOneAsArray());

        vm.stopPrank();

        assertEq(syndicate.sETHStakedBalanceForKnot(blsPubKeyOne, accountOne), 12 ether);
        assertEq(syndicate.sETHUserClaimForKnot(blsPubKeyOne, accountOne), eip1559Reward / 2);

        assertEq(accountOne.balance, (eip1559Reward / 2));
        assertEq(address(syndicate).balance, 0);
    }

    // todo - use fuzz to continually add eip1559 rewards and then have users randomly draw down
}
