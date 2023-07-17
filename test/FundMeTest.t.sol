// SPDX-License-Indentifier: MIT

pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

// we are extending upon the Test contract using inheritance
// Test are by default ran on a new anvil chain and the chain is shutdown once the tests are finished
contract FundMeTest is Test {
    FundMe fundMe;

    // this will run first before any other functions are triggered.
    function setUp() external {
        // FundMe fundMe = new FundMe(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e)
        // constructing our FundMe contract here would mean we will need to modify multiple codes each time we change environment
        // Is there a way to use .env file inside Solidity?

        // We are using the deploy script contract to have consistency across system while testing and deploying
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testDollarMinimumAmountIsFive() public {
        // every test functions should start with 'test'
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwnerThisContract() public {
        // here msg.sender will give us the address that initiated the test
        // since our FundMe contract is deployed by the FundMeTest contract, the owner will be FundMeTest contract instead
        // assertEq(fundMe.i_owner(), address(this)); // we get access to address because this is basically a contract

        // Since we are using the deploy script the address now, the owner of this contract has changed to msg.sender
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testIfConnectionSuccessful() public {
        // Check the connection to priceFeed by getting the version which should be int(4)
        assertEq(fundMe.getVersion(), 4);
    }
}
