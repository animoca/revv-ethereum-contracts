// SPDX-License-Identifier: MIT

pragma solidity 0.8.14;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/ForwarderRegistryContextBase.sol";

contract BaseBlueprintFacet is ForwarderRegistryContextBase {
    address internal immutable _cars;
    address internal immutable _revv;
    address internal immutable _cata;

    constructor(
        address cars,
        address revv,
        address cata,
        IForwarderRegistry forwarderRegistry
    ) ForwarderRegistryContextBase(forwarderRegistry) {
        _cars = cars;
        _revv = revv;
        _cata = cata;
    }
}
