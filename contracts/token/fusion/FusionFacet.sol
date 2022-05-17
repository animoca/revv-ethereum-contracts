// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ProxyAdminStorage} from "@animoca/ethereum-contracts/contracts/proxy/libraries/ProxyAdminStorage.sol";
import {OwnershipStorage} from "@animoca/ethereum-contracts/contracts/access/libraries/OwnershipStorage.sol";
import {FusionStorage} from "./libraries/FusionStorage.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/ForwarderRegistryContextBase.sol";

/// @title Fusion Facet.
/// @dev This contract is to be used as a diamond facet (see ERC2535 Diamond Standard https://eips.ethereum.org/EIPS/eip-2535).
/// @dev Note: This facet depends on {ProxyAdminFacet}, {OwnableFacet} and {PayoutWalletFacet}.
contract FusionFacet is ForwarderRegistryContextBase {
    using ProxyAdminStorage for ProxyAdminStorage.Layout;
    using OwnershipStorage for OwnershipStorage.Layout;
    using FusionStorage for FusionStorage.Layout;

    constructor(IForwarderRegistry forwarderRegistry) ForwarderRegistryContextBase(forwarderRegistry) {}

    function initFusionStorage(address yard_) external {
        ProxyAdminStorage.layout().enforceIsProxyAdmin(_msgSender());
        FusionStorage.layout().init(yard_);
    }

    function setYard(address yard_) external {
        OwnershipStorage.layout().enforceIsContractOwner(_msgSender());
        FusionStorage.layout().yard = yard_;
    }

    function yard() external view returns (address) {
        return FusionStorage.layout().yard;
    }

    function chassisNumber(uint256 carModel) external view returns (uint256) {
        return FusionStorage.layout().chassisNumbers[carModel];
    }
}
