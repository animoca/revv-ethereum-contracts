// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IERC20} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20.sol";
import {IERC20Burnable} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Burnable.sol";
import {IERC721} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721.sol";
import {IERC721BatchTransfer} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721BatchTransfer.sol";
import {IERC721Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC721/interfaces/IERC721Mintable.sol";
import {PayoutWalletStorage} from "@animoca/ethereum-contracts/contracts/payment/libraries/PayoutWalletStorage.sol";
import {ProxyInitialization} from "@animoca/ethereum-contracts/contracts/proxy/libraries/ProxyInitialization.sol";

library FusionStorage {
    using FusionStorage for FusionStorage.Layout;
    using PayoutWalletStorage for PayoutWalletStorage.Layout;

    struct Layout {
        mapping(uint256 => uint256) chassisNumbers;
        address yard;
    }

    bytes32 internal constant LAYOUT_STORAGE_SLOT = bytes32(uint256(keccak256("animoca.revvracing.Fusion.storage")) - 1);
    bytes32 internal constant PROXY_INIT_PHASE_SLOT = bytes32(uint256(keccak256("animoca.revvracing.Fusion.phase")) - 1);

    uint256 internal constant CHASSIS_MASK = 0xfffffff80000000000000000ff00000000000000000000000000ffff00000000;
    uint256 internal constant CHASSIS_NUMBER_MASK = 0x00000000000000000000000000000000000000000000000000000000ffffffff;

    function init(Layout storage s, address yard) internal {
        ProxyInitialization.setPhase(PROXY_INIT_PHASE_SLOT, 1);
        s.yard = yard;
    }

    function setYard(Layout storage s, address yard) internal {
        s.yard = yard;
    }

    function consumeREVV(address revv, address from, uint256 value) internal {
        IERC20(revv).transferFrom(from, PayoutWalletStorage.layout().payoutWallet(), value);
    }

    function consumeCATA(address cata, address from, uint256 value) internal {
        IERC20Burnable(cata).burnFrom(from, value);
    }

    function consumeCar(Layout storage s, address cars, address from, uint256 id) internal {
        IERC721(cars).transferFrom(from, s.yard, id);
    }

    function batchConsumeCars(Layout storage s, address cars, address from, uint256[] memory ids) internal {
        IERC721BatchTransfer(cars).batchTransferFrom(from, s.yard, ids);
    }

    function createCar(Layout storage s, address cars, address to, uint256 carOutputBaseId) internal {
        validateCarOutputBaseId(carOutputBaseId);
        IERC721Mintable(cars).mint(to, s.getNextId(carOutputBaseId));
    }

    function getNextId(Layout storage s, uint256 carOutputBaseId) internal returns (uint256) {
        return carOutputBaseId | ++s.chassisNumbers[carOutputBaseId & CHASSIS_MASK];
    }

    function validateCarOutputBaseId(uint256 carOutputBaseId) internal pure {
        require(carOutputBaseId & CHASSIS_NUMBER_MASK == 0, "Fusion: invalid output base id");
    }

    function layout() internal pure returns (Layout storage s) {
        bytes32 position = LAYOUT_STORAGE_SLOT;
        assembly {
            s.slot := position
        }
    }
}
