//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

//Importing from github @chainlink/contracts are hosted by npm on github
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // we will create 2 functions that might be needed later on
    // getPrice will get the price of ETH/USD
    // getConversionRate will get the conversion interms of the price

    // we will pass the aggregator interface through the contract using this
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData(); // destructuring the data to get only the needed information
        return uint256(price) * 1e10;
    }

    // This is where the math in Solidity gets tricky
    // Solidity doesn't work well with decimals since all basic data types accept only whole numbers
    // Will need to understand this better;
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed); // here we are calling a function internally
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }
}
