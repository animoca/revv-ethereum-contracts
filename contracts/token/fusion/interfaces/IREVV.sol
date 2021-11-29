// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

interface IREVV {
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}
