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
}
