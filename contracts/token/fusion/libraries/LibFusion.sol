// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IREVVRacingCar} from "./../interfaces/IREVVRacingCar.sol";
import {IREVVMotorsportCatalyst} from "./../interfaces/IREVVMotorsportCatalyst.sol";
import {IREVV} from "./../interfaces/IREVV.sol";
import {IChassisCounters} from "./../interfaces/IChassisCounters.sol";

library LibFusion {
    bytes32 public constant FUSION_STORAGE_POSITION = keccak256("revvracing.fusion.storage");

    struct FusionStorage {
        bool initialised;
        // Blueprint contract addresses
        mapping(uint256 => address) blueprints;
        // Tokens for fusion
        IREVVRacingCar cars;
        IREVVMotorsportCatalyst catalysts;
        IREVV revv;
        // Minting counters
        IChassisCounters counters;
        // Recipients
        address payoutWallet;
        address yard;
    }

    function fusionStorage() internal pure returns (FusionStorage storage fs) {
        bytes32 position = FUSION_STORAGE_POSITION;
        assembly {
            fs.slot := position
        }
    }

    function initFusionStorage(
        IREVVRacingCar cars_,
        IREVVMotorsportCatalyst catalysts_,
        IREVV revv_,
        IChassisCounters counters_,
        address payoutWallet_,
        address yard_
    ) internal {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        require(!fs.initialised, "Fusion: storage initialised");
        fs.initialised = true;
        fs.cars = cars_;
        fs.catalysts = catalysts_;
        fs.revv = revv_;
        fs.counters = counters_;
        fs.payoutWallet = payoutWallet_;
        fs.yard = yard_;
    }

    function setBlueprint(uint256 blueprintId, address blueprintAddress) internal {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        fs.blueprints[blueprintId] = blueprintAddress;
    }

    function setPayoutWallet(address payoutWallet) internal {
        LibFusion.FusionStorage storage fs = LibFusion.fusionStorage();
        fs.payoutWallet = payoutWallet;
    }
}
