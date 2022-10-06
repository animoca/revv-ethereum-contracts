// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ERC20MintBurn} from "./ERC20MintBurn.sol";

contract REVVRacingCatalyst is ERC20MintBurn {
    constructor(IForwarderRegistry forwarderRegistry) ERC20MintBurn("REVV Racing Catalyst", "CATA", 18, forwarderRegistry) {}
}
