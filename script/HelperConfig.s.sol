// SPDX-Licence-Identifier: MIT
pragma solidity 0.8.18;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// This contract will give us the configurations needed for chains that are specified
// We are including Goerli Testnet and Anvil (local) chain
contract HelperConfig is Script {
    // CONSTANTS
    uint256 MAINNET_CHAIN_ID = 1;
    uint256 GOERLI_CHAIN_ID = 5;
    uint256 SEPOLIA_CHAIN_ID = 11155111;

    uint8 DECIMALS = 8;
    int64 INITIAL_PRICE = 2000e8;

    // We are creating a special object here NetworkConfig
    // This is the type that can be expected back from any methods|contract using this HelperConfig
    struct NetworkConfig {
        address ethUSDPriceFeedAddress;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainnetETHConfig();
        } else if (block.chainid == GOERLI_CHAIN_ID) {
            activeNetworkConfig = getGoerliETHConfig();
        } else if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();
        }
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory mainnetConfig = NetworkConfig({
            ethUSDPriceFeedAddress: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }

    function getGoerliETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory goerliConfig = NetworkConfig({
            ethUSDPriceFeedAddress: 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
        });
        return goerliConfig;
    }

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            ethUSDPriceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.ethUSDPriceFeedAddress != address(0)) {
            return activeNetworkConfig;
        }
        // Since we are sure to be on an anvil local chain these codes will run on our local machine
        vm.startBroadcast();
        // Here a mock is created of the Aggregator and deployed to local chain
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        // the deployed contract will have an address which we will put into the NetworkConfig for anvil and return it
        NetworkConfig memory anvilConfig = NetworkConfig({
            ethUSDPriceFeedAddress: address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}
