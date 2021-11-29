// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IForwarderRegistry} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/IForwarderRegistry.sol";
import {IERC20Mintable} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/interfaces/IERC20Mintable.sol";
import {ManagedIdentity} from "@animoca/ethereum-contracts-core/contracts/metatx/ManagedIdentity.sol";
import {Recoverable} from "@animoca/ethereum-contracts-core/contracts/utils/Recoverable.sol";
import {UsingUniversalForwarding} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/UsingUniversalForwarding.sol";
import {MinterRole} from "@animoca/ethereum-contracts-core/contracts/access/MinterRole.sol";
import {PolygonChildERC20Burnable} from "@animoca/ethereum-contracts-assets/contracts/token/ERC20/polygon/child/PolygonChildERC20Burnable.sol";

/**
 * @title REVV Motorsport Catalyst Shards.
 */
contract PolygonREVVMotorsportShard is Recoverable, UsingUniversalForwarding, PolygonChildERC20Burnable, IERC20Mintable, MinterRole {
    constructor(IForwarderRegistry forwarderRegistry, address childChainManager)
        PolygonChildERC20Burnable("REVV Motorsport Shard", "SHRD", 18, childChainManager)
        MinterRole(msg.sender)
        UsingUniversalForwarding(forwarderRegistry, address(0))
    {}

    //================================================ ERC20Metadata (admin) ================================================//

    /**
     * Sets the token metadata URI.
     * @dev Reverts if not called by the contract owner.
     * @param tokenURI_ the new token metadata URI.
     */
    function setTokenURI(string calldata tokenURI_) external {
        _requireOwnership(_msgSender());
        _tokenURI = tokenURI_;
    }

    //================================================ ERC20Mintable (admin) ================================================//

    /// @inheritdoc IERC20Mintable
    /// @dev Reverts if the sender is not a minter.
    function mint(address to, uint256 value) public virtual override {
        _requireMinter(_msgSender());
        _mint(to, value);
    }

    /// @inheritdoc IERC20Mintable
    /// @dev Reverts if the sender is not a minter.
    function batchMint(address[] memory recipients, uint256[] memory values) public virtual override {
        _requireMinter(_msgSender());
        _batchMint(recipients, values);
    }

    //======================================== Meta Transactions Internal Functions =========================================//

    function _msgSender() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (address payable) {
        return UsingUniversalForwarding._msgSender();
    }

    function _msgData() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (bytes memory ret) {
        return UsingUniversalForwarding._msgData();
    }
}
