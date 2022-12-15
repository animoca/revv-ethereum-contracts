// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IOperatorFilterRegistry} from "@animoca/ethereum-contracts/contracts/token/royalty/interfaces/IOperatorFilterRegistry.sol";
import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ERC1155WithOperatorFilterer} from "@animoca/ethereum-contracts/contracts/token/ERC1155/ERC1155WithOperatorFilterer.sol";
import {ERC1155Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC1155/ERC1155Mintable.sol";
import {ERC1155Deliverable} from "@animoca/ethereum-contracts/contracts/token/ERC1155/ERC1155Deliverable.sol";
import {ERC1155MetadataURIWithBaseURI} from "@animoca/ethereum-contracts/contracts/token/ERC1155/ERC1155MetadataURIWithBaseURI.sol";
import {ERC1155Burnable} from "@animoca/ethereum-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";
import {ERC2981} from "@animoca/ethereum-contracts/contracts/token/royalty/ERC2981.sol";
import {TokenRecovery} from "@animoca/ethereum-contracts/contracts/security/TokenRecovery.sol";
import {ContractOwnership} from "@animoca/ethereum-contracts/contracts/access/ContractOwnership.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/base/ForwarderRegistryContextBase.sol";
import {ForwarderRegistryContext} from "@animoca/ethereum-contracts/contracts/metatx/ForwarderRegistryContext.sol";

contract REVVMotorsportVouchers is
    ERC1155WithOperatorFilterer,
    ERC1155Mintable,
    ERC1155Deliverable,
    ERC1155MetadataURIWithBaseURI,
    ERC1155Burnable,
    ERC2981,
    TokenRecovery,
    ForwarderRegistryContext
{
    constructor(
        IOperatorFilterRegistry filterRegistry,
        IForwarderRegistry forwarderRegistry
    )
        ERC1155WithOperatorFilterer(filterRegistry)
        ERC1155MetadataURIWithBaseURI()
        ERC1155Mintable()
        ERC1155Deliverable()
        ERC1155Burnable()
        ForwarderRegistryContext(forwarderRegistry)
        ContractOwnership(msg.sender)
    {}

    /// @inheritdoc ForwarderRegistryContextBase
    function _msgSender() internal view virtual override(Context, ForwarderRegistryContextBase) returns (address) {
        return ForwarderRegistryContextBase._msgSender();
    }

    /// @inheritdoc ForwarderRegistryContextBase
    function _msgData() internal view virtual override(Context, ForwarderRegistryContextBase) returns (bytes calldata) {
        return ForwarderRegistryContextBase._msgData();
    }
}
