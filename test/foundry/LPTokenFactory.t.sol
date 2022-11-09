import "forge-std/Test.sol";
import "forge-std/console.sol";

import { LPTokenFactory } from "../../contracts/liquid-staking/LPTokenFactory.sol";
import { LPToken } from "../../contracts/liquid-staking/LPToken.sol";

contract LPTokenFactoryTest is Test {

    address savETHVault = 0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199;
    address accountOne = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    address tokenImplementation;
    LPTokenFactory tokenFactory;

    string nameAndSymbol = "Test";
    LPToken testToken;

    function setUp() public {
        tokenImplementation = address(new LPToken());
        tokenFactory = new LPTokenFactory(tokenImplementation);

        testToken = LPToken(tokenFactory.deployLPToken(savETHVault, address(0), nameAndSymbol, nameAndSymbol));
    }

    function testSetupIsCorrect() public {
        assertEq(tokenFactory.lpTokenImplementation(), tokenImplementation);
    }

    function testTokenDeploymentRevertsWhenSavETHVaultIsZero() public {
        vm.expectRevert("Zero address");
        tokenFactory.deployLPToken(
            address(0),
            address(0),
            "Test",
            "Test"
        );
    }

    function testTokenDeploymentRevertsWhenSymbolIsEmpty() public {
        vm.expectRevert("Symbol cannot be zero");
        tokenFactory.deployLPToken(
            msg.sender,
            address(0),
            "",
            "Test"
        );
    }

    function testTokenDeploymentRevertsWhenNameIsEmpty() public {
        vm.expectRevert("Name cannot be zero");
        tokenFactory.deployLPToken(
            msg.sender,
            address(0),
            "Test",
            ""
        );
    }

    function testTokenDeploymentIsSuccessfulWithCorrectParams() public {
        assertEq(testToken.name(), nameAndSymbol);
        assertEq(testToken.symbol(), nameAndSymbol);
        assertEq(testToken.deployer(), savETHVault);
        assertEq(testToken.totalSupply(), 0);
        assertEq(testToken.balanceOf(accountOne), 0);
    }

    function testOnlySavETHVaultCanMint() public {
        vm.prank(accountOne);
        vm.expectRevert("Only savETH vault");
        testToken.mint(accountOne, 500 ether);
    }

    function testOnlySavETHVaultCanBurn() public {
        vm.prank(accountOne);
        vm.expectRevert("Only savETH vault");
        testToken.burn(accountOne, 500 ether);
    }

    function testMint() public {
        vm.prank(savETHVault);
        testToken.mint(accountOne, 25 ether);
        assertEq(testToken.balanceOf(accountOne), 25 ether);
    }

    function testBurn() public {
        vm.startPrank(savETHVault);
        testToken.mint(accountOne, 25 ether);
        testToken.burn(accountOne, 25 ether);
        vm.stopPrank();
        assertEq(testToken.balanceOf(accountOne), 0);
    }
}