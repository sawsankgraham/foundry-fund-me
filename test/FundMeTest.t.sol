// SPDX-License-Indentifier: MIT

pragma solidity 0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

// we are extending upon the Test contract using inheritance
contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        // this will run first before any other functions are triggered.
        fundMe = new FundMe();
    }

    function testDollarMinimumAmountIsFive() public {
        // every test functions should start with 'test'
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testIsOwnerThisContract() public {
        // here msg.sender will give us the address that initiated the test
        // since our FundMe contract is deployed by the FundMeTest contract, the owner will be FundMeTest contract instead
        assertEq(fundMe.i_owner(), address(this)); // we get access to address because this is basically a contract
    }
}
