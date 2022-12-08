// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IOperatorFilterRegistry} from "@animoca/ethereum-contracts/contracts/token/royalty/interfaces/IOperatorFilterRegistry.sol";
import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVMotorsportVouchers} from "./../../../token/ERC1155/REVVMotorsportVouchers.sol";

contract REVVMotorsportVouchersMock is REVVMotorsportVouchers {
    constructor(
        IOperatorFilterRegistry filterRegistry,
        IForwarderRegistry forwarderRegistry
    ) REVVMotorsportVouchers(filterRegistry, forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
