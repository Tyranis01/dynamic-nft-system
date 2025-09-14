// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./interfaces/IMetadataRenderer.sol";

/**
 * @title MetadataRenderer
 * @dev Generates dynamic metadata and SVG images for NFTs based on their state
 */
contract MetadataRenderer is IMetadataRenderer, Ownable {
    using Strings for uint256;

    // Color schemes for different weather conditions
    mapping(string => string) public weatherColors;
    mapping(string => string) public timeColors;
    mapping(string => string) public weatherBackgrounds;

    // Base SVG template parts
    string public constant SVG_HEADER =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="400" height="400">';
    string public constant SVG_FOOTER = "</svg>";

    constructor() Ownable(msg.sender) {
        _initializeColorSchemes();
    }

    /**
     * @dev Initialize color schemes for weather and time
     */
    function _initializeColorSchemes() internal {
        // Weather colors
        weatherColors["sunny"] = "#FFD700";
        weatherColors["cloudy"] = "#87CEEB";
        weatherColors["rainy"] = "#4682B4";
        weatherColors["stormy"] = "#2F4F4F";
        weatherColors["snowy"] = "#F0F8FF";
        weatherColors["foggy"] = "#D3D3D3";

        // Time of day colors
        timeColors["morning"] = "#FFA07A";
        timeColors["afternoon"] = "#87CEFA";
        timeColors["evening"] = "#DDA0DD";
        timeColors["night"] = "#191970";

        // Weather backgrounds
        weatherBackgrounds["sunny"] = "linear-gradient(45deg, #FFD700, #FFA500)";
        weatherBackgrounds["cloudy"] = "linear-gradient(45deg, #87CEEB, #B0C4DE)";
        weatherBackgrounds["rainy"] = "linear-gradient(45deg, #4682B4, #5F9EA0)";
        weatherBackgrounds["stormy"] = "linear-gradient(45deg, #2F4F4F, #696969)";
        weatherBackgrounds["snowy"] = "linear-gradient(45deg, #F0F8FF, #E6E6FA)";
        weatherBackgrounds["foggy"] = "linear-gradient(45deg, #D3D3D3, #C0C0C0)";
    }

    /**
     * @dev Render complete metadata for a token (implements IMetadataRenderer)
     */
    function renderMetadata(uint256 tokenId, IMetadataRenderer.NFTState memory state)
        external
        view
        override
        returns (string memory)
    {
        string memory svg = _generateSVG(tokenId, state);

        string memory attributes = _generateAttributes(state);

        string memory metadata = string(
            abi.encodePacked(
                '{"name": "Dynamic NFT #',
                tokenId.toString(),
                '", "description": "A dynamic NFT that changes based on weather, time, and user interactions", "image": "data:image/svg+xml;base64,',
                Base64.encode(bytes(svg)),
                '", "attributes": [',
                attributes,
                "]}"
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", Base64.encode(bytes(metadata))));
    }

    /**
     * @dev Generate SVG image based on NFT state
     */
    function _generateSVG(
        uint256 tokenId,
        IMetadataRenderer.NFTState memory state
    ) internal view returns (string memory) {
        string memory background = _getBackgroundGradient(state.currentWeather, state.currentTimeOfDay);
        string memory weatherElement = _getWeatherElement(state.currentWeather);
        string memory timeElement = _getTimeElement(state.currentTimeOfDay);
        string memory actionElement = _getActionElement(state.userActionCount);
        string memory tokenText = _getTokenText(tokenId);
        
        return string(abi.encodePacked(
            SVG_HEADER,
            background,
            weatherElement,
            timeElement,
            actionElement,
            tokenText,
            SVG_FOOTER
        ));
    }
}
