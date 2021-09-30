// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

// solhint-disable max-line-length
import {ERC1155721Inventory, ERC1155721InventoryBurnable} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/token/ERC1155721/ERC1155721InventoryBurnable.sol";
import {IERC1155721InventoryMintable} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/token/ERC1155721/IERC1155721InventoryMintable.sol";
import {IERC1155721InventoryDeliverable} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/token/ERC1155721/IERC1155721InventoryDeliverable.sol";
import {IERC1155InventoryCreator} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/token/ERC1155/IERC1155InventoryCreator.sol";
import {BaseMetadataURI} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/metadata/BaseMetadataURI.sol";
import {MinterRole} from "@animoca/ethereum-contracts-core-1.1.1/contracts/access/MinterRole.sol";
import {ManagedIdentity, Recoverable} from "@animoca/ethereum-contracts-core-1.1.1/contracts/utils/Recoverable.sol";
import {Pausable} from "@animoca/ethereum-contracts-core-1.1.1/contracts/lifecycle/Pausable.sol";
import {IForwarderRegistry, UsingUniversalForwarding} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/UsingUniversalForwarding.sol";

// solhint-enable max-line-length

contract REVVMotorsportInventory is
    ERC1155721InventoryBurnable,
    IERC1155721InventoryMintable,
    IERC1155721InventoryDeliverable,
    IERC1155InventoryCreator,
    BaseMetadataURI,
    MinterRole,
    Pausable,
    Recoverable,
    UsingUniversalForwarding
{
    constructor(IForwarderRegistry forwarderRegistry, address universalForwarder)
        ERC1155721Inventory("REVV Motorsport Inventory", "REVVM")
        MinterRole(msg.sender)
        Pausable(false)
        UsingUniversalForwarding(forwarderRegistry, universalForwarder)
    {}

    // ===================================================================================================
    //                                 User Public Functions
    // ===================================================================================================

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1155InventoryCreator).interfaceId || super.supportsInterface(interfaceId);
    }

    //================================== ERC1155MetadataURI =======================================/

    /// @dev See {IERC1155MetadataURI-uri(uint256)}.
    function uri(uint256 id) public view virtual override returns (string memory) {
        return _uri(id);
    }

    //================================== ERC1155InventoryCreator =======================================/

    /// @dev See {IERC1155InventoryCreator-creator(uint256)}.
    function creator(uint256 collectionId) external view override returns (address) {
        return _creator(collectionId);
    }

    // ===================================================================================================
    //                               Admin Public Functions
    // ===================================================================================================

    // Destroys the contract
    function deprecate() external {
        _requirePaused();
        address payable sender = _msgSender();
        _requireOwnership(sender);
        selfdestruct(sender);
    }

    /**
     * Creates a collection.
     * @dev Reverts if the sender is not the contract owner.
     * @dev Reverts if `collectionId` does not represent a collection.
     * @dev Reverts if `collectionId` has already been created.
     * @dev Emits a {IERC1155Inventory-CollectionCreated} event.
     * @param collectionId Identifier of the collection.
     */
    function createCollection(uint256 collectionId) external {
        _requireOwnership(_msgSender());
        _createCollection(collectionId);
    }

    //================================== Pausable =======================================/

    function pause() external virtual {
        _requireOwnership(_msgSender());
        _pause();
    }

    function unpause() external virtual {
        _requireOwnership(_msgSender());
        _unpause();
    }

    //================================== ERC721 =======================================/

    function transferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        _requireNotPaused();
        super.transferFrom(from, to, nftId);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory nftIds
    ) public virtual override {
        _requireNotPaused();
        super.batchTransferFrom(from, to, nftIds);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        _requireNotPaused();
        super.safeTransferFrom(from, to, nftId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {
        _requireNotPaused();
        super.safeTransferFrom(from, to, nftId, data);
    }

    function batchBurnFrom(address from, uint256[] memory nftIds) public virtual override {
        _requireNotPaused();
        super.batchBurnFrom(from, nftIds);
    }

    //================================== ERC1155 =======================================/

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {
        _requireNotPaused();
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        _requireNotPaused();
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) public virtual override {
        _requireNotPaused();
        super.burnFrom(from, id, value);
    }

    function batchBurnFrom(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override {
        _requireNotPaused();
        super.batchBurnFrom(from, ids, values);
    }

    //================================== ERC1155721InventoryMintable =======================================/

    /**
     * Unsafely mints a Non-Fungible Token (ERC721-compatible).
     * @dev See {IERC1155721InventoryMintable-batchMint(address,uint256)}.
     */
    function mint(address to, uint256 nftId) public virtual override {
        _requireMinter(_msgSender());
        _mint(to, nftId, "", false);
    }

    /**
     * Unsafely mints a batch of Non-Fungible Tokens (ERC721-compatible).
     * @dev See {IERC1155721InventoryMintable-batchMint(address,uint256[])}.
     */
    function batchMint(address to, uint256[] memory nftIds) public virtual override {
        _requireMinter(_msgSender());
        _batchMint(to, nftIds);
    }

    /**
     * Safely mints a Non-Fungible Token (ERC721-compatible).
     * @dev See {IERC1155721InventoryMintable-safeMint(address,uint256,bytes)}.
     */
    function safeMint(
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {
        _requireMinter(_msgSender());
        _mint(to, nftId, data, true);
    }

    /**
     * Safely mints some token (ERC1155-compatible).
     * @dev See {IERC1155721InventoryMintable-safeMint(address,uint256,uint256,bytes)}.
     */
    function safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes memory data
    ) public virtual override {
        _requireMinter(_msgSender());
        _safeMint(to, id, value, data);
    }

    /**
     * Safely mints a batch of tokens (ERC1155-compatible).
     * @dev See {IERC1155721InventoryMintable-safeBatchMint(address,uint256[],uint256[],bytes)}.
     */
    function safeBatchMint(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        _requireMinter(_msgSender());
        _safeBatchMint(to, ids, values, data);
    }

    /**
     * Safely mints tokens to recipients.
     * @dev See {IERC1155721InventoryDeliverable-safeDeliver(address[],uint256[],uint256[],bytes)}.
     */
    function safeDeliver(
        address[] calldata recipients,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external virtual override {
        _requireMinter(_msgSender());
        _safeDeliver(recipients, ids, values, data);
    }

    function _msgSender() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (address payable) {
        return UsingUniversalForwarding._msgSender();
    }

    function _msgData() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (bytes memory ret) {
        return UsingUniversalForwarding._msgData();
    }
}
