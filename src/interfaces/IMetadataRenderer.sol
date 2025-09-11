// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IMetadataRenderer {
    struct NFTState {
        uint256 lastWeatherUpdate;
        uint256 lastTimeUpdate;
        uint256 userActionCount;
        string currentWeather;
        string currentTimeOfDay;
        address owner;
        uint256 createdAt;
    }

    function renderMetadata(uint256 tokenId, NFTState memory state) external view returns (string memory);
}
