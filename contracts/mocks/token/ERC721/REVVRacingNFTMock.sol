// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IOperatorFilterRegistry} from "@animoca/ethereum-contracts/contracts/token/royalty/interfaces/IOperatorFilterRegistry.sol";
import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVRacingNFT} from "./../../../token/ERC721/REVVRacingNFT.sol";

contract REVVRacingNFTMock is REVVRacingNFT {
    constructor(IOperatorFilterRegistry filterRegistry, IForwarderRegistry forwarderRegistry) REVVRacingNFT(filterRegistry, forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
