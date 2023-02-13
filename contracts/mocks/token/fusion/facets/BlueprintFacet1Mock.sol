// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {BlueprintFacet1} from "./../../../../token/fusion/facets/BlueprintFacet1.sol";

contract BlueprintFacet1Mock is BlueprintFacet1 {
    constructor(
        address cars,
        address revv,
        address cata,
        IForwarderRegistry forwarderRegistry
    ) BlueprintFacet1(cars, revv, cata, forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }

    // function fuseWrongbaseOutputCarId(uint256 id) external {
    function fuseWrongbaseOutputCarId() external {
        _fuseOne(
            57910179610855898424928160541739439616390594228285406698647671381124387438592,
            0x800800080000003000000005047a5a60e60d20d2000000000002000400000001, // chassis number is not 0
            // 57910179610855898424928160547579767348767212279596058158364205242864464035840,
            // id,
            57910179610855898424928160541739447587297712243704648546123968643847459705108,
            300 ether,
            1 ether
        );
    }
}
