pragma solidity ^0.8.13;

import "forge-std/console.sol";

import { MockLiquidStakingManager } from "../../contracts/testing/liquid-staking/MockLiquidStakingManager.sol";
import { MockSavETHVault } from "../../contracts/testing/liquid-staking/MockSavETHVault.sol";
import { LPTokenFactory } from "../../contracts/liquid-staking/LPTokenFactory.sol";
import { LPToken } from "../../contracts/liquid-staking/LPToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SyndicateMock } from "../../contracts/testing/syndicate/SyndicateMock.sol";
import { MockBrandNFT } from "../../contracts/testing/stakehouse/MockBrandNFT.sol";
import { MockLSDNFactory } from "../../contracts/testing/liquid-staking/MockLSDNFactory.sol";
import { OwnableSmartWalletFactory } from "../../contracts/smart-wallet/OwnableSmartWalletFactory.sol";
import { SavETHVaultDeployer } from "../../contracts/liquid-staking/SavETHVaultDeployer.sol";
import { StakingFundsVaultDeployer } from "../../contracts/liquid-staking/StakingFundsVaultDeployer.sol";
import { OptionalGatekeeperFactory } from "../../contracts/liquid-staking/OptionalGatekeeperFactory.sol";
import { TestUtils } from "../utils/TestUtils.sol";

contract SavETHVaultTest is TestUtils {

    LPTokenFactory tokenFactory;
    MockLiquidStakingManager liquidStakingManager;

    function setUp() public {
        vm.startPrank(accountFive); // this will mean it gets dETH initial supply
        factory = createMockLSDNFactory();
        vm.stopPrank();

        liquidStakingManager = deployDefaultLiquidStakingNetwork(factory, admin);

        savETHVault = MockSavETHVault(address(liquidStakingManager.savETHVault()));
        assertEq(savETHVault.dETHToken().balanceOf(accountFive), 125_000 ether);
    }

    function testSetupWasSuccessful() public {
        assertEq(address(savETHVault.accountMan()), factory.accountMan()); // to ensure dependency injection is correct
        assertEq(savETHVault.dETHToken().balanceOf(accountFive), 125_000 ether);
        assertEq(savETHVault.indexOwnedByTheVault(), 1);
        assertEq(savETHVault.numberOfLPTokensIssued(), 0);
    }

    function testDepositETHForStakingRevertsWhenInitialsNotRegisteredForBLSKey() public {
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);
        vm.expectRevert("Lifecycle status must be one");
        savETHVault.depositETHForStaking{value: 0}(blsPubKeyOne, 0);
    }

    function testDepositETHForStakingRevertsWhenAmountIsZero() public {
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);
        vm.expectRevert("Min amount not reached");
        savETHVault.depositETHForStaking{value: 0}(blsPubKeyOne, 0);
    }

    function testDepositETHForStakingRevertsWhenAmountDoesNotMatchValue() public {
        vm.deal(accountOne, 5 ether);
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.startPrank(accountOne);
        vm.expectRevert("Must provide correct amount of ETH");
        savETHVault.depositETHForStaking{value: 5}(blsPubKeyOne, 2 ether);
        vm.stopPrank();
    }

    function testFirstDepositDeploysAnLPToken() public {
        uint256 stakeAmount = 24 ether;
        vm.deal(accountOne, stakeAmount);
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);
        assertEq(token.balanceOf(accountOne), stakeAmount);
        assertEq(accountOne.balance, 0);
        assertEq(savETHVault.KnotAssociatedWithLPToken(token), blsPubKeyOne);
        assertEq(savETHVault.numberOfLPTokensIssued(), 1);
    }

    // Fuzz deposits
    function testFirstDepositsForKnotAreBetweenOneAndTwentyFour(uint256 stakeAmount) public {
        vm.assume(stakeAmount >= 0.001 ether);
        vm.assume(stakeAmount <= 24 ether);
        vm.deal(accountOne, stakeAmount);
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);
        assertEq(token.balanceOf(accountOne), stakeAmount);
        assertEq(accountOne.balance, 0);
        assertEq(savETHVault.KnotAssociatedWithLPToken(token), blsPubKeyOne);
        assertEq(savETHVault.numberOfLPTokensIssued(), 1);
    }

    function testSecondDepositForKnotMintsSameLP() public {
        uint256 stakeAmount = 12 ether;
        vm.deal(accountOne, stakeAmount);

        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);
        assertEq(token.balanceOf(accountOne), stakeAmount);

        vm.deal(accountTwo, stakeAmount);
        vm.prank(accountTwo);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);
        assertEq(token.balanceOf(accountOne), stakeAmount);
        assertEq(token.balanceOf(accountTwo), stakeAmount);
        assertEq(token.totalSupply(), stakeAmount * 2);
        assertEq(savETHVault.numberOfLPTokensIssued(), 1);

        // try staking again and expect revert
        vm.deal(accountOne, stakeAmount);
        vm.expectRevert("Amount exceeds the staking limit for the validator");
        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);
    }

    function testBurnLPRevertsWhenAmountIsZero() public {
        vm.expectRevert("Amount cannot be zero");
        savETHVault.burnLPToken(LPToken(address(0)), 0);
    }

    function testBurnLPRevertsWhenBalanceIsZero() public {
        uint256 stakeAmount = 12 ether;
        vm.deal(accountOne, stakeAmount);

        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);

        vm.expectRevert("Not enough balance");
        savETHVault.burnLPToken(token, 14 ether);
    }

    function testBurnLPRevertsWhenETHIsStaked() public {
        uint256 stakeAmount = 12 ether;
        vm.deal(accountOne, stakeAmount);

        // set BLS lifecycle to initials registered
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);

        // set BLS lifecycle to deposited
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 2);

        vm.expectRevert("Cannot burn LP tokens");
        vm.prank(accountOne);
        savETHVault.burnLPToken(token, stakeAmount);
    }

    function testBurnLPBeforeETHIsStaked() public {
        uint256 stakeAmount = 12 ether;
        vm.deal(accountOne, stakeAmount);

        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken token = savETHVault.lpTokenForKnot(blsPubKeyOne);

        // Fast forward time 3 hours ahead to allow for ETH withrawal
        vm.warp(block.timestamp + 3 hours);

        assertEq(accountOne.balance, 0);

        vm.startPrank(accountOne);
        savETHVault.burnLPToken(token, stakeAmount);
        vm.stopPrank();

        assertEq(accountOne.balance, stakeAmount);
    }

    function testWithdrawETHForStakingRevertsWhenNotManager() public {
        vm.expectRevert("Not the savETH vault manager");
        savETHVault.withdrawETHForStaking(accountOne, 24 ether);
    }

    function testWithdrawETHForStakingRevertsWhenAmountIsZero() public {
        vm.prank(address(liquidStakingManager));
        vm.expectRevert("Amount cannot be less than 24 ether");
        savETHVault.withdrawETHForStaking(accountOne, 22 ether);
    }

    function testWithdrawETHForStakingWorksAsExpected() public {
        MockLiquidStakingManager newLiquidStakingManager = MockLiquidStakingManager(payable(factory.deployNewMockLiquidStakingDerivativeNetwork(
                admin,
                true,
                "LSD"
            )));

        MockSavETHVault savETHVault2 = MockSavETHVault(address(newLiquidStakingManager.savETHVault()));

        uint256 stakeAmount = 24 ether;

        address savETHVaultAddress = address(savETHVault2);
        assertEq(savETHVaultAddress.balance, 0);

        vm.deal(savETHVaultAddress, stakeAmount);

        address lsm = address(newLiquidStakingManager);
        assertEq(lsm.balance, 0);
        assertEq(savETHVaultAddress.balance, stakeAmount);
        assertEq(lsm, address(savETHVault2.liquidStakingManager()));

        assertEq(accountTwo.balance, 0);

        vm.prank(lsm);
        savETHVault2.withdrawETHForStaking(accountTwo, stakeAmount);

        assertEq(accountTwo.balance, stakeAmount);
        assertEq(savETHVaultAddress.balance, 0);
    }

    function testBurnLPForDerivativeETHFromStakehouseAfterKnotFormation() public {
        // First supply ETH when validator is at initials registered phase
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        uint256 stakeAmount = 24 ether;
        vm.deal(accountOne, stakeAmount);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken lp = savETHVault.lpTokenForKnot(blsPubKeyOne);

        // Move lifecycle straight to tokens minted i.e. knot has been created and savETH added to vault
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 3);

        // send dETH to the vault as if the vault has withdrawn
        IERC20 dETHToken = savETHVault.dETHToken();
        assertEq(dETHToken.balanceOf(accountFive), 125_000 ether);
        vm.startPrank(accountFive);
        dETHToken.transfer(address(savETHVault.saveETHRegistry()), 24 ether);
        vm.stopPrank();
        assertEq(dETHToken.balanceOf(address(savETHVault.saveETHRegistry())), 24 ether);
        assertEq(dETHToken.balanceOf(accountOne), 0);

        assertEq(lp.balanceOf(accountOne), 24 ether);
        vm.prank(accountOne);
        savETHVault.burnLPToken(lp, stakeAmount);
        assertEq(dETHToken.balanceOf(accountOne), 24 ether);
        assertEq(lp.balanceOf(accountOne), 0);

        (uint256 balance, bool withdrawn) = savETHVault.dETHForKnot(blsPubKeyOne);
        assertEq(withdrawn, true);
        assertEq(balance, 24 ether);
    }

    function testBurnLPForDerivativeETHFromStakehouseAfterKnotFormationAndBalIncrease() public {
        // First supply ETH when validator is at initials registered phase
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 1);
        liquidStakingManager.setIsPartOfNetwork(blsPubKeyOne, true);

        uint256 stakeAmount = 24 ether;
        vm.deal(accountOne, stakeAmount);

        vm.prank(accountOne);
        savETHVault.depositETHForStaking{value: stakeAmount}(blsPubKeyOne, stakeAmount);

        LPToken lp = savETHVault.lpTokenForKnot(blsPubKeyOne);

        // Move lifecycle straight to tokens minted i.e. knot has been created and savETH added to vault
        savETHVault.accountMan().setLifecycleStatus(blsPubKeyOne, 3);

        // send dETH to the vault as if the vault has withdrawn
        IERC20 dETHToken = savETHVault.dETHToken();
        vm.startPrank(accountFive);
        dETHToken.transfer(address(savETHVault.saveETHRegistry()), 24.1 ether);
        vm.stopPrank();
        assertEq(dETHToken.balanceOf(address(savETHVault.saveETHRegistry())), 24.1 ether);
        assertEq(dETHToken.balanceOf(accountOne), 0);

        savETHVault.saveETHRegistry().setBalInIndex(1, blsPubKeyOne, 24.1 ether);

        assertEq(lp.balanceOf(accountOne), 24 ether);
        vm.prank(accountOne);
        savETHVault.burnLPToken(lp, stakeAmount);
        assertEq(dETHToken.balanceOf(accountOne), 24.1 ether);
        assertEq(lp.balanceOf(accountOne), 0);

        (uint256 balance, bool withdrawn) = savETHVault.dETHForKnot(blsPubKeyOne);
        assertEq(withdrawn, true);
        assertEq(balance, 24.1 ether);
    }
}