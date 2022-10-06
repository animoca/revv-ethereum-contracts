// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVRacingCatalyst} from "./../../../token/ERC20/REVVRacingCatalyst.sol";

contract REVVRacingCatalystMock is REVVRacingCatalyst {
    constructor(IForwarderRegistry forwarderRegistry) REVVRacingCatalyst(forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
