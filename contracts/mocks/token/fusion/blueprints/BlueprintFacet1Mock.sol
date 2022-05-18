// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {BlueprintFacet1} from "./../../../../token/fusion/blueprints/BlueprintFacet1.sol";

contract BlueprintFacet1Mock is BlueprintFacet1 {
    constructor(
        address cars,
        address revv,
        address cata,
        IForwarderRegistry forwarderRegistry
    ) BlueprintFacet1(cars, revv, cata, forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
