// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

interface IChassisCounters {
    function incrementCounter(uint256 tokenType) external returns (uint256);
}