// SPDX-License-Indentifier: MIT
pragma solidity 0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// here we are extending upon the Script contract provided by the forge-std libraryf
contract DeployFundMe is Script {
    // this is the method that runs upon running the script
    function run() external returns (FundMe) {
        // any computation runs before broadcasting are run on a simulated environment -> does not cost gas
        HelperConfig helperConfig = new HelperConfig();
        address ethUSDPriceFeedAddress = helperConfig.activeNetworkConfig();

        // after broadcasting the consecutive runs are a real "transaction" -> costs gas
        vm.startBroadcast();

        // We will be using the Goerli Testnet for ETH/USD price for that we need
        // Address: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        // ABI:

        FundMe fundMe = new FundMe(ethUSDPriceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}
