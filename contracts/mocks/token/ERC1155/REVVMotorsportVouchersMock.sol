// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVMotorsportVouchers} from "./../../../token/ERC1155/REVVMotorsportVouchers.sol";

contract REVVMotorsportVouchersMock is REVVMotorsportVouchers {
    constructor(IForwarderRegistry forwarderRegistry) REVVMotorsportVouchers(forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
