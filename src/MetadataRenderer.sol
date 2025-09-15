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
    function _generateSVG(uint256 tokenId, IMetadataRenderer.NFTState memory state)
        internal
        view
        returns (string memory)
    {
        string memory background = _getBackgroundGradient(state.currentWeather, state.currentTimeOfDay);
        string memory weatherElement = _getWeatherElement(state.currentWeather);
        string memory timeElement = _getTimeElement(state.currentTimeOfDay);
        string memory actionElement = _getActionElement(state.userActionCount);
        string memory tokenText = _getTokenText(tokenId);

        return string(
            abi.encodePacked(SVG_HEADER, background, weatherElement, timeElement, actionElement, tokenText, SVG_FOOTER)
        );
    }

    /**
     * @dev Generate background gradient
     */
    function _getBackgroundGradient(string memory weather, string memory timeOfDay)
        internal
        view
        returns (string memory)
    {
        string memory weatherGradient = weatherBackgrounds[weather];
        string memory timeColor = timeColors[timeOfDay];

        return string(
            abi.encodePacked(
                '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
                '<stop offset="0%" style="stop-color:',
                timeColor,
                ';stop-opacity:0.7" />',
                '<stop offset="100%" style="stop-color:',
                weatherColors[weather],
                ';stop-opacity:0.9" />',
                "</linearGradient></defs>",
                '<rect width="400" height="400" fill="url(#bg)" />'
            )
        );
    }

    /**
     * @dev Generate weather-specific visual element
     */
    function _getWeatherElement(string memory weather) internal pure returns (string memory) {
        if (keccak256(abi.encodePacked(weather)) == keccak256(abi.encodePacked("sunny"))) {
            return
            '<circle cx="100" cy="100" r="40" fill="#FFD700" /><g stroke="#FFA500" stroke-width="3" stroke-linecap="round"><line x1="60" y1="60" x2="70" y2="70" /><line x1="140" y1="60" x2="130" y2="70" /><line x1="100" y1="40" x2="100" y2="30" /><line x1="100" y1="170" x2="100" y2="160" /></g>';
        } else if (keccak256(abi.encodePacked(weather)) == keccak256(abi.encodePacked("rainy"))) {
            return
            '<ellipse cx="100" cy="80" rx="30" ry="20" fill="#87CEEB" /><g stroke="#4682B4" stroke-width="2" stroke-linecap="round"><line x1="80" y1="120" x2="85" y2="140" /><line x1="100" y1="120" x2="105" y2="140" /><line x1="120" y1="120" x2="125" y2="140" /></g>';
        } else if (keccak256(abi.encodePacked(weather)) == keccak256(abi.encodePacked("snowy"))) {
            return
            '<g fill="#F0F8FF" stroke="#E6E6FA" stroke-width="1"><polygon points="100,70 110,90 90,90" /><polygon points="120,100 130,120 110,120" /><polygon points="80,110 90,130 70,130" /></g>';
        } else if (keccak256(abi.encodePacked(weather)) == keccak256(abi.encodePacked("cloudy"))) {
            return
            '<ellipse cx="90" cy="80" rx="25" ry="15" fill="#87CEEB" /><ellipse cx="110" cy="85" rx="30" ry="20" fill="#B0C4DE" />';
        } else if (keccak256(abi.encodePacked(weather)) == keccak256(abi.encodePacked("stormy"))) {
            return
            '<ellipse cx="100" cy="70" rx="35" ry="25" fill="#2F4F4F" /><polygon points="100,110 85,140 95,140 80,170 110,140 100,140 115,120" fill="#FFD700" />';
        } else {
            return '<ellipse cx="100" cy="80" rx="40" ry="30" fill="#D3D3D3" opacity="0.8" />';
        }
    }

    /**
     * @dev Generate time-specific visual element
     */
    function _getTimeElement(string memory timeOfDay) internal pure returns (string memory) {
        if (keccak256(abi.encodePacked(timeOfDay)) == keccak256(abi.encodePacked("morning"))) {
            return
            '<rect x="300" y="50" width="80" height="20" fill="#FFA07A" opacity="0.7" rx="10" /><text x="340" y="65" text-anchor="middle" fill="white" font-size="12">Morning</text>';
        } else if (keccak256(abi.encodePacked(timeOfDay)) == keccak256(abi.encodePacked("afternoon"))) {
            return
            '<rect x="300" y="50" width="80" height="20" fill="#87CEFA" opacity="0.7" rx="10" /><text x="340" y="65" text-anchor="middle" fill="white" font-size="12">Afternoon</text>';
        } else if (keccak256(abi.encodePacked(timeOfDay)) == keccak256(abi.encodePacked("evening"))) {
            return
            '<rect x="300" y="50" width="80" height="20" fill="#DDA0DD" opacity="0.7" rx="10" /><text x="340" y="65" text-anchor="middle" fill="white" font-size="12">Evening</text>';
        } else {
            return
            '<rect x="300" y="50" width="80" height="20" fill="#191970" opacity="0.7" rx="10" /><text x="340" y="65" text-anchor="middle" fill="white" font-size="12">Night</text><circle cx="320" cy="100" r="3" fill="white" /><circle cx="350" cy="110" r="2" fill="white" /><circle cx="360" cy="90" r="2" fill="white" />';
        }
    }

    /**
     * @dev Generate user action visual element
     */
    function _getActionElement(uint256 actionCount) internal pure returns (string memory) {
        if (actionCount == 0) {
            return '<circle cx="50" cy="350" r="20" fill="gray" opacity="0.5" />';
        } else if (actionCount <= 5) {
            return
            '<circle cx="50" cy="350" r="20" fill="green" /><text x="50" y="355" text-anchor="middle" fill="white" font-size="12">Active</text>';
        } else if (actionCount <= 10) {
            return
            '<circle cx="50" cy="350" r="25" fill="orange" /><text x="50" y="355" text-anchor="middle" fill="white" font-size="10">Very Active</text>';
        } else {
            return
            '<circle cx="50" cy="350" r="30" fill="red" /><text x="50" y="355" text-anchor="middle" fill="white" font-size="8">Super Active</text>';
        }
    }

    /**
     * @dev Generate token ID text
     */
    function _getTokenText(uint256 tokenId) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<text x="200" y="380" text-anchor="middle" fill="white" font-size="14" font-weight="bold">#',
                tokenId.toString(),
                "</text>"
            )
        );
    }

    /**
     * @dev Generate JSON attributes array
     */
    function _generateAttributes(IMetadataRenderer.NFTState memory state) internal view returns (string memory) {
        return string(
            abi.encodePacked(
                '{"trait_type": "Weather", "value": "',
                state.currentWeather,
                '"},',
                '{"trait_type": "Time of Day", "value": "',
                state.currentTimeOfDay,
                '"},',
                '{"trait_type": "User Actions", "value": ',
                state.userActionCount.toString(),
                ', "display_type": "number"},',
                '{"trait_type": "Age (Hours)", "value": ',
                ((block.timestamp - state.createdAt) / 3600).toString(),
                ', "display_type": "number"}'
            )
        );
    }

    /**
     * @dev Update color scheme (only owner)
     */
    function updateWeatherColor(string calldata weather, string calldata color) external onlyOwner {
        weatherColors[weather] = color;
    }

    function updateTimeColor(string calldata timeOfDay, string calldata color) external onlyOwner {
        timeColors[timeOfDay] = color;
    }

    function updateWeatherBackground(string calldata weather, string calldata background) external onlyOwner {
        weatherBackgrounds[weather] = background;
    }
}
