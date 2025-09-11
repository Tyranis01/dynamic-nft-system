// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IDataOracle {
    function getData() external view returns (string memory);
}
