// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {Recoverable} from "@animoca/ethereum-contracts-core/contracts/utils/Recoverable.sol";
import {MinterRole} from "@animoca/ethereum-contracts-core/contracts/access/MinterRole.sol";
import {IChassisCounters} from "./interfaces/IChassisCounters.sol";

contract ChassisCounters is IChassisCounters, Recoverable, MinterRole {
    mapping(uint256 => uint256) public counters;

    constructor() MinterRole(msg.sender) {}

    function incrementCounter(uint256 tokenType) external override returns (uint256) {
        _requireMinter(msg.sender);
        return ++counters[tokenType];
    }
}
