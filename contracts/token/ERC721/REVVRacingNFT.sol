// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {ERC721} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721.sol";
import {ERC721Deliverable} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721Deliverable.sol";
import {ERC721BatchTransfer} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721BatchTransfer.sol";
import {ERC721MetadataWithBaseURI} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721MetadataWithBaseURI.sol";
import {ERC721Burnable} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721Burnable.sol";
import {ERC721Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC721/ERC721Mintable.sol";
import {TokenRecovery} from "@animoca/ethereum-contracts/contracts/security/TokenRecovery.sol";
import {ContractOwnership} from "@animoca/ethereum-contracts/contracts/access/ContractOwnership.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ForwarderRegistryContextBase} from "@animoca/ethereum-contracts/contracts/metatx/base/ForwarderRegistryContextBase.sol";
import {ForwarderRegistryContext} from "@animoca/ethereum-contracts/contracts/metatx/ForwarderRegistryContext.sol";

contract REVVRacingNFT is
    ERC721,
    ERC721BatchTransfer,
    ERC721MetadataWithBaseURI,
    ERC721Burnable,
    ERC721Mintable,
    ERC721Deliverable,
    TokenRecovery,
    ForwarderRegistryContext
{
    constructor(IForwarderRegistry forwarderRegistry)
        ERC721MetadataWithBaseURI("REVV Racing NFT", "RR")
        ContractOwnership(msg.sender)
        ForwarderRegistryContext(forwarderRegistry)
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
