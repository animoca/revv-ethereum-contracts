// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IForwarderRegistry} from "@animoca/ethereum-contracts/contracts/metatx/interfaces/IForwarderRegistry.sol";
import {REVVRacingNFT} from "./../../../token/ERC721/REVVRacingNFT.sol";

contract REVVRacingNFTMock is REVVRacingNFT {
    constructor(IForwarderRegistry forwarderRegistry) REVVRacingNFT(forwarderRegistry) {}

    function __msgData() external view returns (bytes calldata) {
        return _msgData();
    }
}
