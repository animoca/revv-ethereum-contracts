// SPDX-License-Identifier: MIT

pragma solidity ^0.6.8;

import "@animoca/ethereum-contracts-assets/contracts/token/ERC1155721/ERC1155721InventoryBurnable.sol";
import "@animoca/ethereum-contracts-assets/contracts/token/ERC1155721/IERC1155721InventoryMintable.sol";
import "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/IERC1155InventoryCreator.sol";
import "@animoca/ethereum-contracts-assets/contracts/metadata/BaseMetadataURI.sol";
import "@animoca/ethereum-contracts-core/contracts/access/MinterRole.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract REVVInventory is
    Ownable,
    Pausable,
    ERC1155721InventoryBurnable,
    IERC1155721InventoryMintable,
    IERC1155InventoryCreator,
    BaseMetadataURI,
    MinterRole
{
    // solhint-disable-next-line const-name-snakecase
    string public constant override name = "REVV Inventory";
    // solhint-disable-next-line const-name-snakecase
    string public constant override symbol = "REVV-I";

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

    //================================== Pausable =======================================/

    function pause() external virtual {
        require(owner() == _msgSender(), "Inventory: not the owner");
        _pause();
    }

    function unpause() external virtual {
        require(owner() == _msgSender(), "Inventory: not the owner");
        _unpause();
    }

    //================================== ERC1155Inventory =======================================/

    /**
     * Creates a collection.
     * @dev Reverts if `collectionId` does not represent a collection.
     * @dev Reverts if `collectionId` has already been created.
     * @dev Emits a {IERC1155Inventory-CollectionCreated} event.
     * @param collectionId Identifier of the collection.
     */
    function createCollection(uint256 collectionId) external onlyOwner {
        _createCollection(collectionId);
    }

    //================================== ERC1155721InventoryMintable =======================================/

    /**
     * Unsafely mints a Non-Fungible Token (ERC721-compatible).
     * @dev See {IERC1155721InventoryMintable-batchMint(address,uint256)}.
     */
    function mint(address to, uint256 nftId) public virtual override {
        require(isMinter(_msgSender()), "Inventory: not a minter");
        _mint(to, nftId, "", false);
    }

    /**
     * Unsafely mints a batch of Non-Fungible Tokens (ERC721-compatible).
     * @dev See {IERC1155721InventoryMintable-batchMint(address,uint256[])}.
     */
    function batchMint(address to, uint256[] memory nftIds) public virtual override {
        require(isMinter(_msgSender()), "Inventory: not a minter");
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
        require(isMinter(_msgSender()), "Inventory: not a minter");
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
        require(isMinter(_msgSender()), "Inventory: not a minter");
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
        require(isMinter(_msgSender()), "Inventory: not a minter");
        _safeBatchMint(to, ids, values, data);
    }

    //================================== ERC721 =======================================/

    function transferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.transferFrom(from, to, nftId);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory nftIds
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.batchTransferFrom(from, to, nftIds);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, nftId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 nftId,
        bytes memory data
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, nftId, data);
    }

    function batchBurnFrom(address from, uint256[] memory nftIds) public virtual override {
        require(!paused(), "Inventory: paused");
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
        require(!paused(), "Inventory: paused");
        super.safeTransferFrom(from, to, id, value, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.safeBatchTransferFrom(from, to, ids, values, data);
    }

    function burnFrom(
        address from,
        uint256 id,
        uint256 value
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.burnFrom(from, id, value);
    }

    function batchBurnFrom(
        address from,
        uint256[] memory ids,
        uint256[] memory values
    ) public virtual override {
        require(!paused(), "Inventory: paused");
        super.batchBurnFrom(from, ids, values);
    }
}
