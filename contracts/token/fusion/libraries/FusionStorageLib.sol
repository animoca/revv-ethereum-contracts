// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IChassisCounters} from "./../interfaces/IChassisCounters.sol";

interface IREVV {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

interface IREVVMotorsportCatalyst {
    function burnFrom(address from, uint256 value) external returns (bool);
}

interface IREVVRacingCar {
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;

    function safeMint(
        address to,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external;

    function safeBatchMint(
        address to,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external;
}

library FusionStorageLib {
    bytes32 constant FUSION_STORAGE_POSITION = keccak256("revvracing.fusion.proxy.storage");

    struct FusionStorage {
        // IERC173
        address contractOwner;

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
}