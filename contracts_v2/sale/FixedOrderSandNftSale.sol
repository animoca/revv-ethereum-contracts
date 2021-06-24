// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "@animoca/ethereum-contracts-sale_base-8.0.0/contracts/sale/FixedOrderInventorySale.sol";

/**
 * @title FixedOrderSandNftSale
 * A FixedOrderInventorySale contract implementation that handles the purchases of Sandbox NFTs
 * track NFTs from a holder account to the recipient. The provisioning of the NFTs from the holder
 * account occurs in a sequential order defined by a token list. Only a single SKU is supported.
 */
contract FixedOrderSandNftSale is FixedOrderInventorySale {
    address public immutable tokenHolder;

    /**
     * Constructor.
     * @dev Reverts if `inventory` is the zero address.
     * @dev Reverts if `tokenHolder` is the zero address.
     * @dev Emits the `MagicValues` event.
     * @dev Emits the `Paused` event.
     * @param inventory The inventory contract from which the NFT sale supply is attributed from.
     * @param tokenHolder_ The account holding the pool of sale inventory NFTs.
     * @param payoutWallet The payout wallet.
     * @param tokensPerSkuCapacity the cap for the number of tokens managed per SKU.
     */
    constructor(
        address inventory,
        address tokenHolder_,
        address payoutWallet,
        uint256 tokensPerSkuCapacity
    ) public FixedOrderInventorySale(inventory, payoutWallet, tokensPerSkuCapacity) {
        // solhint-disable-next-line reason-string
        require(tokenHolder_ != address(0), "FixedOrderSandNftSale: zero address token holder");

        tokenHolder = tokenHolder_;
    }

    /**
     * Creates an SKU.
     * @dev Reverts if called by any other than the contract owner.
     * @dev Reverts if called when the contract is not paused.
     * @dev Reverts if the initial sale supply is empty.
     * @dev Reverts if `sku` already exists.
     * @dev Reverts if `notificationsReceiver` is not the zero address and is not a contract address.
     * @dev Reverts if the update results in too many SKUs.
     * @dev Emits the `SkuCreation` event.
     * @param sku the SKU identifier.
     * @param maxQuantityPerPurchase The maximum allowed quantity for a single purchase.
     * @param notificationsReceiver The purchase notifications receiver contract address.
     *  If set to the zero address, the notification is not enabled.
     */
    function createSku(
        bytes32 sku,
        uint256 maxQuantityPerPurchase,
        address notificationsReceiver
    ) external onlyOwner whenPaused {
        _createSku(sku, tokenList.length, maxQuantityPerPurchase, notificationsReceiver);
    }

    /**
     * Lifecycle step which delivers the purchased SKUs to the recipient.
     * @dev Responsibilities:
     *  - Ensure the product is delivered to the recipient, if that is the contract's responsibility.
     *  - Handle any internal logic related to the delivery, including the remaining supply update.
     *  - Add any relevant extra data related to delivery in `purchase.deliveryData` and document how to interpret it.
     * @dev Reverts if there is not enough available supply.
     * @dev Reverts if this contract does not have the minter role on the inventory contract.
     * @dev Updates `purchase.deliveryData` with the list of tokens allocated from `tokenList` for
     *  this purchase.
     * @dev Mints the tokens allocated in `purchase.deliveryData` to the purchase recipient.
     * @param purchase The purchase conditions.
     */
    function _delivery(PurchaseData memory purchase) internal virtual override {
        super._delivery(purchase);

        uint256[] memory ids = new uint256[](purchase.quantity);
        uint256[] memory values = new uint256[](purchase.quantity);

        for (uint256 index = 0; index != purchase.quantity; ++index) {
            ids[index] = uint256(purchase.deliveryData[index]);
            values[index] = 1;
        }

        IFixedOrderInventoryTransferable(inventory).safeBatchTransferFrom(tokenHolder, purchase.recipient, ids, values, "");
    }
}

/**
 * @dev Interface for the transfer function of the NFT inventory contract.
 */
interface IFixedOrderInventoryTransferable {
    /**
     * @notice Transfers `values` amount(s) of `ids` from the `from` address to the `to` address specified (with safety call).
     * @dev Caller must be approved to manage the tokens being transferred out of the `from` account (see "Approval" section of the standard).
     * MUST revert if `to` is the zero address.
     * MUST revert if length of `ids` is not the same as length of `values`.
     * MUST revert if any of the balance(s) of the holder(s) for token(s) in `ids` is lower than the respective amount(s) in `values` sent to the
     *  recipient.
     * MUST revert on any other error.
     * MUST emit `TransferSingle` or `TransferBatch` event(s) such that all the balance changes are reflected (see "Safe Transfer Rules" section of
     *  the standard).
     * Balance changes and events MUST follow the ordering of the arrays (_ids[0]/_values[0] before _ids[1]/_values[1], etc).
     * After the above conditions for the transfer(s) in the batch are met, this function MUST check if `to` is a smart contract
     *  (e.g. code size > 0). If so, it MUST call the relevant `ERC1155TokenReceiver` hook(s) on `to` and act appropriately (see "Safe Transfer
     *  Rules" section of the standard).
     * @param from    Source address
     * @param to      Target address
     * @param ids     IDs of each token type (order and length must match _values array)
     * @param values  Transfer amounts per token type (order and length must match _ids array)
     * @param data    Additional data with no specified format, MUST be sent unaltered in call to the `ERC1155TokenReceiver` hook(s) on `to`
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}
