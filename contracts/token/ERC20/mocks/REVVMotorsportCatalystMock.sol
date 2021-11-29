// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IForwarderRegistry} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/IForwarderRegistry.sol";
import {REVVMotorsportCatalyst} from "./../REVVMotorsportCatalyst.sol";

contract REVVMotorsportCatalystMock is REVVMotorsportCatalyst {
    constructor(
        address[] memory recipients,
        uint256[] memory values,
        IForwarderRegistry forwarderRegistry
    ) REVVMotorsportCatalyst(forwarderRegistry) {
        _batchMint(recipients, values);
    }

    //=============================================== Mock Coverage Functions ===============================================//

    function msgData() external view returns (bytes memory ret) {
        return _msgData();
    }
}
