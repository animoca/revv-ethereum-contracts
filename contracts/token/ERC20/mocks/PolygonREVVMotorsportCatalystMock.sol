// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IForwarderRegistry} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/IForwarderRegistry.sol";
import {PolygonREVVMotorsportCatalyst} from "./../PolygonREVVMotorsportCatalyst.sol";

contract PolygonREVVMotorsportCatalystMock is PolygonREVVMotorsportCatalyst {
    constructor(IForwarderRegistry forwarderRegistry, address childChainManager)
        PolygonREVVMotorsportCatalyst(forwarderRegistry, childChainManager)
    {}

    //=============================================== Mock Coverage Functions ===============================================//

    function msgData() external view returns (bytes memory ret) {
        return _msgData();
    }
}
