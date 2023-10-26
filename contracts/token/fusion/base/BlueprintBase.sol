// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/base/ForwarderRegistryContextBase.sol";

abstract contract BlueprintBase is ForwarderRegistryContextBase {
    uint256 internal constant CAR_TYPE_MASK = 0xfffffff80000fff000000fffffff000000000000000000000fffffff00000000;

    address internal immutable _cars;
    address internal immutable _revv;
    address internal immutable _cata;

    constructor(address cars, address revv, address cata, IForwarderRegistry forwarderRegistry) ForwarderRegistryContextBase(forwarderRegistry) {
        _cars = cars;
        _revv = revv;
        _cata = cata;
    }

    function _enforceIsValidCar(uint256 id, uint256 matchValue) internal pure {
        require(id & CAR_TYPE_MASK == matchValue, "Fusion: wrong car type");
    }
}
