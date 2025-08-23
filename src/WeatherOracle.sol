// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IDataOracle.sol";

/**
 * @title WeatherOracle
 * @dev Oracle contract that provides weather data for dynamic NFTs
 * This is a mock implementation - in production you'd integrate with real weather APIs
 */
contract WeatherOracle is IDataOracle, Ownable {

    struct WeatherData {
        string condition;
        int256 temperature;
        uint256 timestamp;
        bool isValid;
    }

    // Current weather data
    WeatherData public currentWeather;

    // Authorized updaters (could be Chainlink nodes, API services, etc.)
    mapping(address => bool) public authorizedUpdaters;

    // Weather conditions mapping
    string[] public weatherConditions = [
        "sunny",
        "cloudy", 
        "rainy",
        "stormy",
        "snowy",
        "foggy"
    ];

    // Events
    event WeatherUpdated(string condition, int256 temperature, uint256 timestamp);
    event UpdaterAuthorized(address indexed updater, bool authorized);

    // Constants
    uint256 public constant STALE_DATA_THRESHOLD = 4 hours;

    modifier onlyAuthorizedUpdater() {
        require(authorizedUpdaters[msg.sender] || msg.sender == owner(), "Not authorized updater");
        _;
    }

    constructor() {
        // Initialize with default weather
        currentWeather = WeatherData({
            condition: "sunny",
            temperature: 22,
            timestamp: block.timestamp,
            isValid: true
        });
        
        // Authorize owner as updater
        authorizedUpdaters[msg.sender] = true;
    }

    /**
     * @dev Update weather data
     */
    function updateWeather(string calldata condition, int256 temperature) external onlyAuthorizedUpdater {
        require(bytes(condition).length > 0, "Invalid condition");
        require(_isValidWeatherCondition(condition), "Unknown weather condition");
        
        currentWeather = WeatherData({
            condition: condition,
            temperature: temperature,
            timestamp: block.timestamp,
            isValid: true
        });
        
        emit WeatherUpdated(condition, temperature, block.timestamp);
    }
}
