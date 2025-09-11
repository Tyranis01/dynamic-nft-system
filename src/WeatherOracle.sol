// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
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
    string[] public weatherConditions = ["sunny", "cloudy", "rainy", "stormy", "snowy", "foggy"];

    // Events
    event WeatherUpdated(string condition, int256 temperature, uint256 timestamp);
    event UpdaterAuthorized(address indexed updater, bool authorized);

    // Constants
    uint256 public constant STALE_DATA_THRESHOLD = 4 hours;

    modifier onlyAuthorizedUpdater() {
        require(authorizedUpdaters[msg.sender] || msg.sender == owner(), "Not authorized updater");
        _;
    }

    constructor() Ownable(msg.sender) {
        // Initialize with default weather
        currentWeather = WeatherData({condition: "sunny", temperature: 22, timestamp: block.timestamp, isValid: true});

        // Authorize owner as updater
        authorizedUpdaters[msg.sender] = true;
    }

    /**
     * @dev Update weather data
     */
    function updateWeather(string calldata condition, int256 temperature) external onlyAuthorizedUpdater {
        require(bytes(condition).length > 0, "Invalid condition");
        require(_isValidWeatherCondition(condition), "Unknown weather condition");

        currentWeather =
            WeatherData({condition: condition, temperature: temperature, timestamp: block.timestamp, isValid: true});

        emit WeatherUpdated(condition, temperature, block.timestamp);
    }

    /**
     * @dev Get current weather data (implements IDataOracle)
     */
    function getData() external view returns (string memory) {
        require(currentWeather.isValid, "No valid weather data");
        require(block.timestamp <= currentWeather.timestamp + STALE_DATA_THRESHOLD, "Weather data is stale");

        return currentWeather.condition;
    }

    /**
     * @dev Get detailed weather data
     */
    function getDetailedWeatherData() external view returns (WeatherData memory) {
        return currentWeather;
    }

    /**
     * @dev Generate pseudo-random weather (for demo purposes)
     */
    function generateRandomWeather() external onlyAuthorizedUpdater {
        uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)))
            % weatherConditions.length;

        string memory condition = weatherConditions[randomIndex];

        // Generate random temperature between -10 and 35 Celsius
        int256 temperature =
            int256((uint256(keccak256(abi.encodePacked(block.timestamp + 1, block.difficulty))) % 46)) - 10;

        currentWeather =
            WeatherData({condition: condition, temperature: temperature, timestamp: block.timestamp, isValid: true});

        emit WeatherUpdated(condition, temperature, block.timestamp);
    }

    /**
     * @dev Check if weather condition is valid
     */
    function _isValidWeatherCondition(string memory condition) internal view returns (bool) {
        for (uint256 i = 0; i < weatherConditions.length; i++) {
            if (keccak256(abi.encodePacked(weatherConditions[i])) == keccak256(abi.encodePacked(condition))) {
                return true;
            }
        }
        return false;
    }

    /**
     * @dev Authorize/unauthorize updaters
     */
    function setAuthorizedUpdater(address updater, bool authorized) external onlyOwner {
        authorizedUpdaters[updater] = authorized;
        emit UpdaterAuthorized(updater, authorized);
    }

    /**
     * @dev Add new weather condition
     */
    function addWeatherCondition(string calldata condition) external onlyOwner {
        weatherConditions.push(condition);
    }

    /**
     * @dev Check if data is stale
     */
    function isDataStale() external view returns (bool) {
        return block.timestamp > currentWeather.timestamp + STALE_DATA_THRESHOLD;
    }

    /**
     * @dev Get last update timestamp
     */
    function getLastUpdateTimestamp() external view returns (uint256) {
        return currentWeather.timestamp;
    }

    /**
     * @dev Get weather condition by index
     */
    function getWeatherCondition(uint256 index) external view returns (string memory) {
        require(index < weatherConditions.length, "Index out of bounds");
        return weatherConditions[index];
    }

    /**
     * @dev Get total weather conditions count
     */
    function getWeatherConditionsCount() external view returns (uint256) {
        return weatherConditions.length;
    }
}
