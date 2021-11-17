// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IREVV, IREVVRacingCar, IREVVMotorsportCatalyst, FusionStorageLib} from "./../libraries/FusionStorageLib.sol";
import {ERC1155TokenReceiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/ERC1155TokenReceiver.sol";
import {IERC1155} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/interfaces/IERC1155.sol";
import {IERC1155InventoryMintable} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/interfaces/IERC1155InventoryMintable.sol";
import {ERC1155TokenReceiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/ERC1155TokenReceiver.sol";

/**
 * @title ERC20 Receiver Mock.
 */
contract BlueprintA is ERC1155TokenReceiver {

    uint256 immutable public spentTokenMask;
    uint256 immutable public deliveredTokenMask;
    uint256 immutable public catalystCost;
    uint256 immutable public revvCost;

    constructor(uint256 spentTokenMask_, uint256 deliveredTokenMask_, uint256 catalystCost_, uint256 revvCost_) {
        spentTokenMask = spentTokenMask_;
        deliveredTokenMask = deliveredTokenMask_;
        catalystCost = catalystCost_;
        revvCost = revvCost_;
    }

    //================================================ ERC1155TokenReceiver =================================================//

    function onERC1155Received(
        address, /*operator,*/
        address from,
        uint256 id,
        uint256 value,
        bytes calldata /*data*/
    ) external override returns (bytes4) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        IREVVRacingCar cars = fs.cars;
        require(msg.sender == address(cars), "Fusion: wrong sender");
        require(id & spentTokenMask == spentTokenMask, "Fusion: wrong token type");
        fs.catalysts.burnFrom(from, catalystCost);
        fs.revv.transferFrom(from, fs.payoutWallet, revvCost);
        cars.safeTransferFrom(address(this), fs.yard, id, value, "");
        cars.safeMint(from, deliveredTokenMask | fs.counters.incrementCounter(deliveredTokenMask), value, "");

        return _ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator,*/
        address, /*from,*/
        uint256[] calldata, /*ids,*/
        uint256[] calldata, /*values,*/
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        revert('Fusion: unsupported call');
    }
}
