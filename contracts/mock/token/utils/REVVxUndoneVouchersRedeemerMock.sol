// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IERC1155InventoryBurnable, IWrappedERC20, REVVxUndoneVouchersRedeemer} from "../../../token/utils/REVVxUndoneVouchersRedeemer.sol";

contract REVVxUndoneVouchersRedeemerMock is REVVxUndoneVouchersRedeemer {
    constructor(
        IERC1155InventoryBurnable vouchersContract,
        IWrappedERC20 tokenContract,
        address tokenHolder
    ) REVVxUndoneVouchersRedeemer(vouchersContract, tokenContract, tokenHolder) {}

    function voucherValue(uint256 tokenId) external pure returns (uint256) {
        return _voucherValue(tokenId);
    }
}
