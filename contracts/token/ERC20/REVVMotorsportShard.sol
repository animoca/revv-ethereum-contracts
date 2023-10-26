// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ERC20MintBurn} from "./ERC20MintBurn.sol";

contract REVVMotorsportShard is ERC20MintBurn {
    constructor(IForwarderRegistry forwarderRegistry) ERC20MintBurn("REVV Motorsport Shard", "SHRD", 18, forwarderRegistry) {}
}
