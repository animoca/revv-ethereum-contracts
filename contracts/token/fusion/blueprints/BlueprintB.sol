// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IREVVRacingCar, LibFusion} from "./../libraries/LibFusion.sol";
import {BlueprintBase} from "./BlueprintBase.sol";

contract BlueprintB is BlueprintBase {
    uint256 public immutable spentTokenMask1;
    uint256 public immutable spentTokenMask2;
    uint256 public immutable deliveredTokenMask;
    uint256 public immutable catalystCost;
    uint256 public immutable revvCost;

    constructor(
        uint256 spentTokenMask1_,
        uint256 spentTokenMask2_,
        uint256 deliveredTokenMask_,
        uint256 catalystCost_,
        uint256 revvCost_
    ) {
        spentTokenMask1 = spentTokenMask1_;
        spentTokenMask2 = spentTokenMask2_;
        deliveredTokenMask = deliveredTokenMask_;
        catalystCost = catalystCost_;
        revvCost = revvCost_;
    }

    //================================================ ERC1155TokenReceiver =================================================//

    function onERC1155Received(
        address, /*operator,*/
        address, /*from,*/
        uint256, /*id,*/
        uint256, /*value,*/
        bytes calldata /*data*/
    ) external pure override returns (bytes4) {
        revert("Fusion: unsupported call");
    }

    function onERC1155BatchReceived(
        address, /*operator,*/
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata /*data*/
    ) external override returns (bytes4) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        IREVVRacingCar cars = fs.cars;
        require(msg.sender == address(cars), "Fusion: wrong sender");
        require(ids.length == 2, "Fusion: incorrect length");
        require(ids[0] & spentTokenMask1 == spentTokenMask1, "Fusion: wrong token1 type");
        require(ids[1] & spentTokenMask2 == spentTokenMask2, "Fusion: wrong token2 type");
        fs.catalysts.burnFrom(from, catalystCost);
        fs.revv.transferFrom(from, fs.payoutWallet, revvCost);
        cars.safeBatchTransferFrom(address(this), fs.yard, ids, values, "");
        cars.safeMint(from, deliveredTokenMask | fs.counters.incrementCounter(deliveredTokenMask), 1, "");
        return _ERC1155_BATCH_RECEIVED;
    }
}
