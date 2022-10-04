// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVMotorsportShard} from "./../../../token/ERC20/REVVMotorsportShard.sol";

contract REVVMotorsportShardMock is REVVMotorsportShard {
    constructor(IForwarderRegistry forwarderRegistry) REVVMotorsportShard(forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
