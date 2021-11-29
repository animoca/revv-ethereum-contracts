// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IERC1155TokenReceiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/interfaces/IERC1155TokenReceiver.sol";

abstract contract BlueprintBase is IERC1155TokenReceiver {
    // bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))
    bytes4 internal constant _ERC1155_RECEIVED = 0xf23a6e61;

    // bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))
    bytes4 internal constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;
}
