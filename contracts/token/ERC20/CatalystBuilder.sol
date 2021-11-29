// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IERC20Receiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/interfaces/IERC20Receiver.sol";
import {IERC20Burnable} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/interfaces/IERC20Burnable.sol";
import {IERC20Mintable} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/interfaces/IERC20Mintable.sol";
import {ERC20Receiver} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/ERC20Receiver.sol";
import {MinterRole} from "@animoca/ethereum-contracts-core/contracts/access/MinterRole.sol";
import {Recoverable} from "@animoca/ethereum-contracts-core/contracts/utils/Recoverable.sol";

/**
 * @title ERC20 Receiver Mock.
 */
contract CatalystBuilder is ERC20Receiver, MinterRole, Recoverable {
    event ConversionRateUpdated(uint256 conversionRate);

    IERC20Burnable public immutable shards;
    IERC20Mintable public immutable catalysts;

    uint256 public conversionRate; // number of shard necessary to build a catalyst

    constructor(IERC20Burnable shards_, IERC20Mintable catalysts_) MinterRole(msg.sender) {
        shards = shards_;
        catalysts = catalysts_;
        emit ConversionRateUpdated(0);
    }

    //==================================================== ERC20Receiver ====================================================//

    /**
     * On safe reception of shards, converts them into catalysts based on the current conversion rate.
     * @dev Reverts if the sender is not the shards contract.
     * @dev Reverts if the conversion rate is currently set to zero.
     * @inheritdoc IERC20Receiver
     */
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

        return _ERC20_RECEIVED;
    }

    //=================================================== CatalystBuilder ===================================================//

    /**
     * Sets the conversion rate.
     * @dev Reverts if not sent by a minter.
     * @dev Emits a ConversionRateUpdated event.
     * @param conversionRate_ the new conversion rate. A zero value disables the conversion.
     */
    function setConversionRate(uint256 conversionRate_) external {
        _requireMinter(_msgSender());
        conversionRate = conversionRate_;
        emit ConversionRateUpdated(conversionRate_);
    }
}
