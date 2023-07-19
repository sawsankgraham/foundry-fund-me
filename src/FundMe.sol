//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner(); // this naming convention will allow us to debug easier by letting us know which contract sent the error

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {
    // Gas cost before making variable minimusUsd constant -> 752,235
    // Gas cost after making variable minimusUsd constant -> 634,564

    // variable to add owner as a state variable
    address private immutable i_owner; // immutable keyword is used on variable that will be assigned during compilation and then cannot change
    // minimum fee that can be funded will be $5
    uint256 public constant MINIMUM_USD = 5e18; // because our conversion rate will have 18 decimal places

    // Constant and Immutable are used to make the contract more gas efficient
    // these keywords will encode these values directly into the bytes of the contract rather than storage
    // this makes the contract more effiecient in terms of gas cost

    // Common convention is the CAPITALIZE all constants and add 'i_' prefix to all immutables

    AggregatorV3Interface ethUSDPriceFeed;

    // Adding a constructor
    // this is called in the same transaction as it is deployed
    constructor(address _ethUSDPriceFeedAddress) {
        i_owner = msg.sender;
        // We will make the constructor take the address of the chainlink ETH/USD data feed
        // This will allow us to feed the address at the time of deployment
        ethUSDPriceFeed = AggregatorV3Interface(_ethUSDPriceFeedAddress);
    }

    // Get version to test the connection to the datafeed is successful
    function getVersion() public view returns (uint256) {
        return ethUSDPriceFeed.version();
    }

    using PriceConverter for uint256; // this will allow us to use the library created as an extension for uint256 variables

    // Common convention for storage variable naming is s_{variableName}

    // array of s_funders to keep track of all addresses who funded
    address[] private s_funders;

    // mapping of s_funders with total amount funded
    mapping(address => uint256) private s_addressToAmountFunded;

    // the price of ether in terms of $ is not a data that is available within the blockchain since it is a realtime data
    // to get the real world data we will be using oracles specifically ChainLink
    // Chainlink is a decentralized oracle network made to be used with Smart Contracts and DApps (Decentralized Apps)

    // Chainlink connection is moved to PriceConverter library

    function fund() public payable {
        // 'payable' keyword makes this function accept payment

        // the amount of wei transferred will be available through the msg.value object
        // msg is what is known as globals, need to study on the globals to understand more

        // require(msg.value > 1e18); // 1 ether is 1 * 10 ** 18 wei the value is always in wei
        // the require keyword will send a error if the given condition is not fulfilled
        // require(condition, message);
        // the getConversionRate is a custum function we added from the PriceConverter library
        require(
            msg.value.getConversionRate(ethUSDPriceFeed) > MINIMUM_USD,
            "Atleast $5 is required"
        ); // we use getConversionRate to get the amount of ETH that is minimum in terms of USD

        // require will revert back the transaction if the condition is failed
        // this means any changes to the state of the contract done before the failed require state will be reverted back
        // the revert will return with the remaining gas fees, subtracting only gas used for computation above it

        // To keep track of the s_funders we push the address that called this method
        s_funders.push(msg.sender); // msg.sender is a global variable accessible to us
        s_addressToAmountFunded[msg.sender] += msg.value; // this will add the sent value to the addresses previous fund total
    }

    function withdraw() public onlyOwner {
        //onlyOwner is a custom modifier

        // msg.sender is of type address
        // payable(msg.sender) is of type payable address
        // we need payable address to transfer money to the address

        // methods of sending eth from a contract are
        // transfer -> throws error and reverts
        // payable(msg.sender).transfer(address(this).balance);

        // send -> throws boolean of success status
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Withdraw failed");

        // call -> is a low level solidity function (study more on this), RECOMMENDED
        (bool callSuccess /* bytes memory dataReturned */, ) = payable(
            msg.sender
        ).call{value: address(this).balance}("");
        require(callSuccess, "Withdraw failed");

        // In the tutorial the storage are cleared after withdraw
        // We will leave the funders and mapping of funders to amount funded as is
        // This will kee
    }

    // modifiers are custom keyword we can define that can be used while declaring a function
    // modifiers run the code inside before jumping to the actual code present in the function

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Only owner is allowed.");

        // note that we can define errors to be more gas effiecient by defining codes to them
        // this is more efficient because this will allow us to not store strings which can be more expensive while storing
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _; // this will run the rest of the code where this modifier is used. Putting it above the require would run the code first and then require.
    }

    // There are other ways to send money to a contract without using any of the specified functions in the ABI
    // In these cases the fund method wouldn't trigger and the s_funders data wouldn't change
    // For this we use 'special' functions such as receive and fallback. For more info look into the FallbackExample contract.

    receive() external payable {
        fund(); //just call the fund method if any money is received from other methods than using our fund() function.
    }

    fallback() external payable {
        fund(); //just call the fund method if any money is received from other methods than using our fund() function.
    }

    // Creating some functions to test the private storage items
    // Private variables are more gas effiecient

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    // Get funders from array by index
    function getFunderFromArrayByIndex(
        uint256 index
    ) external view returns (address) {
        return s_funders[index];
    }

    // Get Owner of the Contract
    function getOwner() external view returns (address) {
        return i_owner;
    }
}
