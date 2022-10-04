// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ERC1155Storage} from "@animoca/ethereum-contracts/contracts/token/ERC1155/libraries/ERC1155Storage.sol";
import {TokenMetadataWithBaseURIStorage} from "@animoca/ethereum-contracts/contracts/token/metadata/libraries/TokenMetadataWithBaseURIStorage.sol";
import {ContractOwnershipStorage} from "@animoca/ethereum-contracts/contracts/access/libraries/ContractOwnershipStorage.sol";
import {ERC1155Base} from "@animoca/ethereum-contracts/contracts/token/ERC1155/base/ERC1155Base.sol";
import {ERC1155MintableBase} from "@animoca/ethereum-contracts/contracts/token/ERC1155/base/ERC1155MintableBase.sol";
import {ERC1155DeliverableBase} from "@animoca/ethereum-contracts/contracts/token/ERC1155/base/ERC1155DeliverableBase.sol";
import {ERC1155MetadataURIWithBaseURIBase} from "@animoca/ethereum-contracts/contracts/token/ERC1155/base/ERC1155MetadataURIWithBaseURIBase.sol";
import {ERC1155BurnableBase} from "@animoca/ethereum-contracts/contracts/token/ERC1155/base/ERC1155BurnableBase.sol";
import {TokenRecoveryBase} from "@animoca/ethereum-contracts/contracts/security/base/TokenRecoveryBase.sol";
import {ContractOwnershipBase} from "@animoca/ethereum-contracts/contracts/access/base/ContractOwnershipBase.sol";
import {AccessControlBase} from "@animoca/ethereum-contracts/contracts/access/base/AccessControlBase.sol";
import {InterfaceDetection} from "@animoca/ethereum-contracts/contracts/introspection/InterfaceDetection.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/base/ForwarderRegistryContextBase.sol";
import {ForwarderRegistryContext} from "@animoca/ethereum-contracts/contracts/metatx/ForwarderRegistryContext.sol";

contract REVVMotorsportVouchers is
    ERC1155Base,
    ERC1155MintableBase,
    ERC1155DeliverableBase,
    ERC1155MetadataURIWithBaseURIBase,
    ERC1155BurnableBase,
    ContractOwnershipBase,
    AccessControlBase,
    InterfaceDetection,
    TokenRecoveryBase,
    ForwarderRegistryContext
{
    using TokenMetadataWithBaseURIStorage for TokenMetadataWithBaseURIStorage.Layout;
    using ContractOwnershipStorage for ContractOwnershipStorage.Layout;

    constructor(IForwarderRegistry forwarderRegistry) ForwarderRegistryContext(forwarderRegistry) {}

    function init(string calldata baseMetadataURI) external {
        address sender = _msgSender();
        ContractOwnershipStorage.layout().proxyInit(sender);
        ERC1155Storage.init();
        ERC1155Storage.initERC1155MetadataURI();
        ERC1155Storage.initERC1155Mintable();
        ERC1155Storage.initERC1155Deliverable();
        ERC1155Storage.initERC1155Burnable();
        TokenMetadataWithBaseURIStorage.layout().proxyInit(baseMetadataURI);
    }

    /// @inheritdoc ForwarderRegistryContextBase
    function _msgSender() internal view virtual override(Context, ForwarderRegistryContextBase) returns (address) {
        return ForwarderRegistryContextBase._msgSender();
    }

    /// @inheritdoc ForwarderRegistryContextBase
    function _msgData() internal view virtual override(Context, ForwarderRegistryContextBase) returns (bytes calldata) {
        return ForwarderRegistryContextBase._msgData();
    }
}
