// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IForwarderRegistry, REVVRacingInventory} from "../../../token/ERC1155721/REVVRacingInventory.sol";

contract REVVRacingInventoryMock is REVVRacingInventory {
    constructor(IForwarderRegistry forwarderRegistry, address universalForwarder) REVVRacingInventory(forwarderRegistry, universalForwarder) {}

    function msgData() external view returns (bytes memory ret) {
        return _msgData();
    }
}
