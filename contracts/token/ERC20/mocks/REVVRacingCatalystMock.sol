// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IForwarderRegistry} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/IForwarderRegistry.sol";
import {REVVRacingCatalyst} from "./../REVVRacingCatalyst.sol";

contract REVVRacingCatalystMock is REVVRacingCatalyst {
    constructor(
        address[] memory recipients,
        uint256[] memory values,
        IForwarderRegistry forwarderRegistry
    ) REVVRacingCatalyst(forwarderRegistry) {
        _batchMint(recipients, values);
    }

    //=============================================== Mock Coverage Functions ===============================================//

    function msgData() external view returns (bytes memory ret) {
        return _msgData();
    }
}
