// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {FusionFacet} from "./../../../token/fusion/FusionFacet.sol";

contract FusionFacetMock is FusionFacet {
    constructor(IForwarderRegistry forwarderRegistry) FusionFacet(forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
