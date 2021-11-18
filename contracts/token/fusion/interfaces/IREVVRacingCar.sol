// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

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
