// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

// solhint-disable-next-line max-line-length
import {IERC1155InventoryBurnable, IWrappedERC20, ERC1155VouchersRedeemer} from "@animoca/ethereum-contracts-assets/contracts/token/utils/ERC1155VouchersRedeemer.sol";

/**
 * @title REVV x Undone Vouchers Redeemer.
 */
contract REVVxUndoneVouchersRedeemer is ERC1155VouchersRedeemer {
    uint256 internal constant _ELIGIBLE_TOKENS_MASK = 57896058422150792899851111632845954022647989576200829067172336848893363879936;
    uint256 internal constant _REDEEMED_VALUE = 10000 * 10**18; // 10,000 REVV

    constructor(
        IERC1155InventoryBurnable vouchersContract,
        IWrappedERC20 tokenContract,
        address tokenHolder
    ) ERC1155VouchersRedeemer(vouchersContract, tokenContract, tokenHolder) {}

    /// @inheritdoc ERC1155VouchersRedeemer
    /// @dev Reverts if `tokenId` is not a REVV x Undone Voucher token.
    function _voucherValue(uint256 tokenId) internal pure override returns (uint256) {
        require(tokenId & _ELIGIBLE_TOKENS_MASK == _ELIGIBLE_TOKENS_MASK, "Redeemer: wrong token");
        return _REDEEMED_VALUE;
    }
}
