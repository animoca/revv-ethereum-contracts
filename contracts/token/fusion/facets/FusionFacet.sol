// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {LibDiamond} from "hardhat-deploy/solc_0.7/diamond/libraries/LibDiamond.sol";
import {LibFusion} from "./../libraries/LibFusion.sol";
import {IREVVRacingCar} from "./../interfaces/IREVVRacingCar.sol";
import {IREVVMotorsportCatalyst} from "./../interfaces/IREVVMotorsportCatalyst.sol";
import {IREVV} from "./../interfaces/IREVV.sol";
import {IChassisCounters} from "./../interfaces/IChassisCounters.sol";
import {IERC1155TokenReceiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/interfaces/IERC1155TokenReceiver.sol";

contract FusionFacet is IERC1155TokenReceiver {
    function initFusionStorage(
        IREVVRacingCar cars_,
        IREVVMotorsportCatalyst catalysts_,
        IREVV revv_,
        IChassisCounters counters_,
        address payoutWallet_,
        address yard_
    ) external {
        LibDiamond.enforceIsContractOwner();

        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.supportedInterfaces[type(IERC1155TokenReceiver).interfaceId] = true;

        LibFusion.initFusionStorage(cars_, catalysts_, revv_, counters_, payoutWallet_, yard_);
    }

    //================================================ ERC1155TokenReceiver =================================================//

    /**
     * Handle the fusion request of a single REVV Racing token.
     * @dev Reverts if the blueprint identifier encoded in `data` is not set.
     * param operator  The address which initiated the transfer (i.e. msg.sender)
     * param from      The address which previously owned the token
     * param id        The ID of the token being transferred
     * param value     The amount of tokens being transferred
     * @param data     The abi-encoded blueprint identifier.
     * @return         `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     */
    function onERC1155Received(
        address, /*operator,*/
        address, /*from,*/
        uint256, /*id,*/
        uint256, /*value,*/
        bytes calldata data
    ) external override returns (bytes4) {
        return _delegateFusionCall(abi.decode(data, (uint256)));
    }

    /**
     * Handle the fusion request of multiple REVV Racing tokens.
     * @dev Reverts if the blueprint identifier encoded in `data` is not set.
     * param operator  The address which initiated the batch transfer (i.e. msg.sender)
     * param from      The address which previously owned the token
     * param ids       An array containing ids of each token being transferred (order and length must match values array)
     * param values    An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data     The abi-encoded blueprint identifier.
     * @return         `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     */
    function onERC1155BatchReceived(
        address, /*operator,*/
        address, /*from,*/
        uint256[] calldata, /*ids,*/
        uint256[] calldata, /*values,*/
        bytes calldata data
    ) external override returns (bytes4) {
        return _delegateFusionCall(abi.decode(data, (uint256)));
    }

    //=============================================== Public Admin Functions ================================================//

    function setBlueprint(uint256 blueprintId, address blueprint_) external {
        LibDiamond.enforceIsContractOwner();
        LibFusion.setBlueprint(blueprintId, blueprint_);
    }

    function setPayoutWallet(address payoutWallet_) external {
        LibDiamond.enforceIsContractOwner();
        LibFusion.setPayoutWallet(payoutWallet_);
    }

    //=================================================== Public Getters ====================================================//

    function blueprint(uint256 blueprintId) external view returns (address) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.blueprints[blueprintId];
    }

    function payoutWallet() external view returns (address) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.payoutWallet;
    }

    function cars() external view returns (IREVVRacingCar) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.cars;
    }

    function revv() external view returns (IREVV) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.revv;
    }

    function catalysts() external view returns (IREVVMotorsportCatalyst) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.catalysts;
    }

    function yard() external view returns (address) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.yard;
    }

    function counters() external view returns (IChassisCounters) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        return fs.counters;
    }

    //============================================== Helper Internal Functions ==============================================//

    function _delegateFusionCall(uint256 blueprintId) internal returns (bytes4) {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        address blueprintAddress = fs.blueprints[blueprintId];
        require(blueprintAddress != address(0), "Fusion: non-existent blueprint");
        // Execute external function from facet using delegatecall and return any value.
        assembly {
            // copy function selector and any arguments
            calldatacopy(0, 0, calldatasize())
            // execute function call using the blueprint
            let result := delegatecall(gas(), blueprintAddress, 0, calldatasize(), 0, 0)
            // get any return value
            returndatacopy(0, 0, returndatasize())
            // return any return value or error back to the caller
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}
