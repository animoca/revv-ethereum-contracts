// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import {IERC20} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20.sol";
import {IERC20Burnable} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Burnable.sol";
import {IERC721} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721.sol";
import {IERC721BatchTransfer} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721BatchTransfer.sol";
import {IERC721Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721Mintable.sol";
import {PayoutWalletStorage} from "@animoca/ethereum-contracts/contracts/payment/libraries/PayoutWalletStorage.sol";
import {StorageVersion} from "@animoca/ethereum-contracts/contracts/proxy/libraries/StorageVersion.sol";

library FusionStorage {
    using FusionStorage for FusionStorage.Layout;

    bytes32 public constant FUSION_STORAGE_POSITION = bytes32(uint256(keccak256("animoca.revvracing.Fusion.storage")) - 1);
    bytes32 public constant FUSION_VERSION_SLOT = bytes32(uint256(keccak256("animoca.revvracing.Fusion.version")) - 1);

    uint256 public constant CHASSIS_MASK = 0xfffffff80000000000000000ff00000000000000000000000000ffff00000000;

    struct Layout {
        mapping(uint256 => uint256) chassisNumbers;
        address yard;
    }

    function init(Layout storage s, address yard) internal {
        StorageVersion.setVersion(FUSION_VERSION_SLOT, 1);
        s.yard = yard;
    }

    function consumeREVV(
        address revv,
        address from,
        uint256 value
    ) internal {
        IERC20(revv).transferFrom(from, PayoutWalletStorage.layout().payoutWallet, value);
    }

    function consumeCATA(
        address cata,
        address from,
        uint256 value
    ) internal {
        IERC20Burnable(cata).burnFrom(from, value);
    }

    function consumeCar(
        Layout storage s,
        address cars,
        address from,
        uint256 id
    ) internal {
        IERC721(cars).transferFrom(from, s.yard, id);
    }

    function batchConsumeCars(
        Layout storage s,
        address cars,
        address from,
        uint256[] memory ids
    ) internal {
        IERC721BatchTransfer(cars).batchTransferFrom(from, s.yard, ids);
    }

    function createCar(
        Layout storage s,
        address cars,
        address to,
        uint256 carOutputBaseId
    ) internal {
        IERC721Mintable(cars).mint(to, s._getNextId(carOutputBaseId));
    }

    // function batchCreateCars(
    //     Layout storage s,
    //     address cars,
    //     address to,
    //     uint256[] calldata carOutputBaseId
    // ) internal {
    //     uint256[] memory ids = new uint256[](carOutputBaseId.length);
    //     for (uint256 i; i != carOutputBaseId.length; ++i) {
    //         ids[i] = s._getNextId(carOutputBaseId[i]);
    //     }
    //     IERC721Mintable(cars).batchMint(to, ids);
    // }

    function enforceIsValidCar(
        uint256 id,
        uint256 mask,
        uint256 matchValue
    ) internal pure {
        require(id & mask == matchValue, "Fusion: wrong car type");
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = FUSION_STORAGE_POSITION;
        assembly {
            s.slot := position
        }
    }

    function _getNextId(Layout storage s, uint256 carOutputBaseId) internal returns (uint256) {
        return carOutputBaseId | ++s.chassisNumbers[carOutputBaseId & CHASSIS_MASK];
    }

    // function _getNextIds(Layout storage s, uint256 carOutputBaseId, uint256 nbIds) internal returns (uint256[] memory) {
    //     uint256 chassisNumberBaseId = carOutputBaseId & CHASSIS_MASK;
    //     uint256 chassisNumber = s.chassisNumbers[chassisNumberBaseId];
    //     uint256[] memory ids = new uint256[](nbIds);
    //     for (uint256 i; i != nbIds; ++i) {
    //         ids[i] = ++chassisNumber;
    //     }
    //     s.chassisNumbers[chassisNumberBaseId] = chassisNumber;
    //     return ids;
    // }
}
