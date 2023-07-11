// SPDX-License-Indentifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script { // here we are extending upon the Script contract provided by the forge-std library


    function run() external returns (FundMe) { // this is the method that runs upon running the script
        vm.startBroadcast();
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
        return fundMe;
    }
}
