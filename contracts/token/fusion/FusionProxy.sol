// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IREVVRacingCar, IREVVMotorsportCatalyst, IREVV, FusionStorageLib} from "./libraries/FusionStorageLib.sol";
import {IChassisCounters} from "./interfaces/IChassisCounters.sol";
import {IERC165} from "@animoca/ethereum-contracts-core/contracts/introspection/IERC165.sol";
import {IERC173} from "@animoca/ethereum-contracts-core/contracts/access/IERC173.sol";
import {ERC1155TokenReceiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC1155/ERC1155TokenReceiver.sol";

// import {MinterRole} from "@animoca/ethereum-contracts-core/contracts/access/MinterRole.sol";
// import {Recoverable} from "@animoca/ethereum-contracts-core/contracts/utils/Recoverable.sol";

contract FusionProxy is ERC1155TokenReceiver, IERC173 {
    constructor(
        IREVVRacingCar cars_,
        IREVVMotorsportCatalyst catalysts_,
        IREVV revv_,
        IChassisCounters counters_,
        address payoutWallet_,
        address yard_
    ) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        fs.cars = cars_;
        fs.catalysts = catalysts_;
        fs.revv = revv_;
        fs.counters = counters_;
        fs.payoutWallet = payoutWallet_;
        fs.yard = yard_;

        fs.contractOwner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    //======================================================= ERC165 ========================================================//

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC173).interfaceId || super.supportsInterface(interfaceId);
    }

    //======================================================= ERC173 ========================================================//

    /// @inheritdoc IERC173
    function owner() external view override returns (address) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.contractOwner;
    }

    /// @inheritdoc IERC173
    function transferOwnership(address newOwner) external override {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        require(msg.sender == fs.contractOwner, "Fusion: not the contract owner");
        fs.contractOwner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
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

    //===================================================== FusionProxy =====================================================//

    function setBlueprint(uint256 blueprintId, address blueprint_/*, bytes calldata calldata_*/) external {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        require(msg.sender == fs.contractOwner, "Fusion: not the contract owner");
        fs.blueprints[blueprintId] = blueprint_;
        /*if (calldata_.length != 0) {
            blueprint_.delegatecall(calldata_);
        }*/
    }

    function setPayoutWallet(address payoutWallet_) external {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        require(msg.sender == fs.contractOwner, "Fusion: not the contract owner");
        fs.payoutWallet = payoutWallet_;
    }

    function blueprint(uint256 blueprintId) external view returns (address) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.blueprints[blueprintId];
    }

    function payoutWallet() external view returns (address) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.payoutWallet;
    }

    function cars() external view returns (IREVVRacingCar) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.cars;
    }

    function revv() external view returns (IREVV) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.revv;
    }

    function catalysts() external view returns (IREVVMotorsportCatalyst) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.catalysts;
    }

    function yard() external view returns (address) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.yard;
    }

    function counters() external view returns (IChassisCounters) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        return fs.counters;
    }

    //============================================== Helper Internal Functions ==============================================//

    function _delegateFusionCall(uint256 blueprintId) internal returns (bytes4) {
        FusionStorageLib.FusionStorage storage fs = FusionStorageLib.fusionStorage();
        address blueprintAddress = fs.blueprints[blueprintId];
        require(blueprintAddress != address(0), "Fusion: blueprint does not exist");
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
