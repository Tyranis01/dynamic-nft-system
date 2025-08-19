// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IDataOracle.sol";
import "./interfaces/IMetadataRenderer.sol";

/**
 * @title DynamicNFT
 * @dev NFT contract that changes metadata based on external data sources
 */
contract DynamicNFT is ERC721, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;

    // Core interfaces
    IDataOracle public weatherOracle;
    IDataOracle public timeOracle;
    IMetadataRenderer public metadataRenderer;


    // Events
    event TokenMinted(uint256 indexed tokenId, address indexed to);
    event MetadataUpdated(uint256 indexed tokenId, string newMetadata);
    event UserActionPerformed(uint256 indexed tokenId, address indexed user, string action);

    // Structs
    struct TokenData {
        uint256 mintTime;
        uint256 lastUpdate;
        uint256 interactionCount;
        string currentWeather;
        uint256 temperature; // In Celsius * 100 (e.g., 2550 = 25.5°C)
        string season;
        address lastInteractor;
    }

    struct WeatherData {
        string condition; // "sunny", "rainy", "cloudy", "snowy"
        uint256 temperature;
        uint256 humidity;
        uint256 timestamp;
    }

    // Storage
    mapping(uint256 => TokenData) public tokenData;
    mapping(address => bool) public authorizedOracles;

    WeatherData public currentWeather;

    // Configuration
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.01 ether;

    // Metadata renderer contract
    address public metadataRenderer;
}
