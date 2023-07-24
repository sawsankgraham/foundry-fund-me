// SPDX-License-Indentifier: MIT

pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/Console.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// we are extending upon the Test contract using inheritance
// Test are by default ran on a new anvil chain and the chain is shutdown once the tests are finished
contract FundMeTest is Test {
    FundMe fundMe;

    // Constants to be used during the tests
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 1 ether;
    address USER = makeAddr("user"); // from forge-std  makes an address mapped to the value provided

    // this will run first before every test functions are triggered.
    function setUp() external {
        // FundMe fundMe = new FundMe(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e)
        // constructing our FundMe contract here would mean we will need to modify multiple codes each time we change environment
        // Is there a way to use .env file inside Solidity?

        // We are using the deploy script contract to have consistency across system while testing and deploying
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    // tests functions should always have the 'test' keyword as a prefix
    function testDollarMinimumAmountIsFive() public {
        // every test functions should start with 'test'
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwnerThisContract() public {
        // here msg.sender will give us the address that initiated the test
        // since our FundMe contract is deployed by the FundMeTest contract, the owner will be FundMeTest contract instead
        // assertEq(fundMe.i_owner(), address(this)); // we get access to address because this is basically a contract

        // Since we are using the deploy script the address now, the owner of this contract has changed to msg.sender
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testIfConnectionSuccessful() public {
        // Check the connection to priceFeed by getting the version which should be int(4)
        assertEq(fundMe.getVersion(), 4);
    }

    // Test the fund me should fail with no value sent
    function testShouldFailIfNoValueIsSent() public {
        vm.expectRevert(); // this will check if the next line will revert
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER); // this makes the transactions below be sent from the USER
        fundMe.fund{value: SEND_VALUE}(); // This will send the data inside {} with the transaction
        _;
    }

    // Test if the data is changed after funded
    // funded modifier will fund the USER account with SEND_VALUE ether
    function testShouldChangeDataAfterFunded() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    // Test if funder is added to the funders array
    function testShouldAddFunderToArray() public funded {
        assertEq(USER, fundMe.getFunderFromArrayByIndex(0));
    }

    // Test if only owner of the contract can call the withdraw function
    function testShoulFailWhenNotOwnerCallsWithdraw() public funded {
        // We will be pranking again because the above prank is done only for the next line which is not a 'cheatcode'
        vm.prank(USER);
        vm.expectRevert(); // this will not reset the pranking user
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        uint256 gasStart = gasleft(); // this will be the gas available in the start
        vm.prank(owner);
        fundMe.withdraw();

        uint256 gasEnd = gasleft(); // this will be the gas left after the transaction is done
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0); // all balance in the contract must be withdrawn
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        ); // the owner must be deposited all the balance in the contract
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange

        // uint160 has the same number of bytes as an address so we can use uint160 to create addresses from address(uint160)
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // hoax is provided byy forge-std and it does vm.prank and vm.deal together
            hoax(address(i), STARTING_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0); // all balance in the contract must be withdrawn
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        ); // the owner must be deposited all the balance in the contract
    }
}
