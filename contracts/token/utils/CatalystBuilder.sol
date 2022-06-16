// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import {IERC20Receiver} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Receiver.sol";
import {IERC20Burnable} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Burnable.sol";
import {IERC20Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Mintable.sol";
import {IERC20Receiver} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Receiver.sol";
import {ERC20Storage} from "@animoca/ethereum-contracts/contracts/token/ERC20/libraries/ERC20Storage.sol";
import {InterfaceDetectionStorage} from "@animoca/ethereum-contracts/contracts/introspection/libraries/InterfaceDetectionStorage.sol";
import {AccessControlStorage} from "@animoca/ethereum-contracts/contracts/access/libraries/AccessControlStorage.sol";
import {ERC20Receiver} from "@animoca/ethereum-contracts/contracts/token/ERC20/ERC20Receiver.sol";
import {ContractOwnership} from "@animoca/ethereum-contracts/contracts/access/ContractOwnership.sol";
import {AccessControl} from "@animoca/ethereum-contracts/contracts/access/AccessControl.sol";
import {TokenRecovery} from "@animoca/ethereum-contracts/contracts/security/TokenRecovery.sol";

/// @title REVV Racing Catalysts Builder which converts SHRD into CATA.
contract REVVRacingCatalystBuilder is ERC20Receiver, AccessControl, TokenRecovery {
    using InterfaceDetectionStorage for InterfaceDetectionStorage.Layout;
    using AccessControlStorage for AccessControlStorage.Layout;

    bytes32 public constant RATE_MANAGER_ROLE = "RATE_MANAGER";

    IERC20Burnable public immutable shards;
    IERC20Mintable public immutable catalysts;

    uint256 public conversionRate; // number of shard necessary to build a catalyst

    event ConversionRateUpdated(uint256 conversionRate);

    constructor(IERC20Burnable shards_, IERC20Mintable catalysts_) ContractOwnership(msg.sender) {
        shards = shards_;
        catalysts = catalysts_;
        emit ConversionRateUpdated(0);
    }

    //==================================================== ERC20Receiver ====================================================//

    /// @notice On safe reception of shards, converts them into catalysts based on the current conversion rate.
    /// @dev Reverts if the sender is not the shards contract.
    /// @dev Reverts if the conversion rate is currently set to zero.
    /// @inheritdoc IERC20Receiver
    function onERC20Received(
        address, /*sender,*/
        address from,
        uint256 value,
        bytes memory /*data*/
    ) public virtual override returns (bytes4) {
        require(msg.sender == address(shards), "CatalystBuilder: wrong sender");

        uint256 rate = conversionRate;
        require(rate != 0, "CatalystBuilder: rate not set");

        shards.burn(value);
        catalysts.mint(from, value / rate);

        return ERC20Storage.ERC20_RECEIVED;
    }

    //=================================================== CatalystBuilder ===================================================//

    /// @notice Sets the conversion rate.
    /// @dev Reverts if not sent by a RATE_MANAGER.
    /// @dev Emits a ConversionRateUpdated event.
    /// @param conversionRate_ the new conversion rate. A zero value disables the conversion.
    function setConversionRate(uint256 conversionRate_) external {
        AccessControlStorage.layout().enforceHasRole(RATE_MANAGER_ROLE, _msgSender());
        conversionRate = conversionRate_;
        emit ConversionRateUpdated(conversionRate_);
    }
}
