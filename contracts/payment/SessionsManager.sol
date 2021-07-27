// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {IWrappedERC20, ERC20Wrapper} from "@animoca/ethereum-contracts-core-1.1.1/contracts/utils/ERC20Wrapper.sol";
import {ManagedIdentity, Ownable, Recoverable} from "@animoca/ethereum-contracts-core-1.1.1/contracts/utils/Recoverable.sol";
import {PayoutWallet} from "@animoca/ethereum-contracts-core-1.1.1/contracts/payment/PayoutWallet.sol";
import {ERC20Receiver} from "@animoca/ethereum-contracts-assets-1.1.3/contracts/token/ERC20/ERC20Receiver.sol";
import {IForwarderRegistry, UsingUniversalForwarding} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/UsingUniversalForwarding.sol";

contract SessionsManager is Recoverable, UsingUniversalForwarding, ERC20Receiver, PayoutWallet {
    using ERC20Wrapper for IWrappedERC20;

    /**
     * Event emitted when a game session has been submitted.
     * @param account the address of the account which entered the session.
     * @param sessionId the session identifier provided by the server.
     * @param amount the amount of REVV paid for the session: 0 for a free session, the current session price otherwise.
     */
    event Admission(address account, string sessionId, uint256 amount);

    IWrappedERC20 public immutable revvToken;

    uint256 public freeSessions; // the total number of free sessions for each account.
    uint256 public sessionPrice; // the current price for a single session.

    mapping(address => uint256) public freeSessionsUsed; // the number of free sessions used by account.

    constructor(
        IForwarderRegistry forwarderRegistry,
        address universalForwarder,
        IWrappedERC20 revvToken_,
        address payable payoutWallet
    ) UsingUniversalForwarding(forwarderRegistry, universalForwarder) PayoutWallet(msg.sender, payoutWallet) {
        revvToken = revvToken_;
    }

    /**
     * Adds `amount` of free sessions.
     * @dev Reverts if the sender is not the contract owner.
     * @dev Reverts if the number of free sessions overflows.
     * @param amount the number of additional free sessions.
     */
    function addFreeSessions(uint256 amount) external {
        _requireOwnership(_msgSender());
        uint256 freeSessions_ = freeSessions;
        uint256 newFreeSessions = freeSessions_ + amount;
        require(newFreeSessions > freeSessions, "Sessions: sessions overflow");
        freeSessions = newFreeSessions;
    }

    /**
     * Sets `price` as the new session price.
     * @dev Reverts if the sender is not the contract owner.
     * @param price the new session price.
     */
    function setSessionPrice(uint256 price) external {
        _requireOwnership(_msgSender());
        sessionPrice = price;
    }

    /**
     * Registers a user to a game session.
     * This function is the entry point when doing a PolygonREVV `safeTransfer` or `safeTransferFrom` to this contract.
     * @dev Reverts if the function is called from another address than the PolygonREVV contract address.
     * @dev Reverts if the session price has not been set yet.
     * @dev Reverts if the received value is incorrect: must be the session price, or zero in case of a free session.
     * @dev Emits an `Admission` event.
     * @param from the initiator of the transfer.
     * @param value the amount of PolygonREVV received.
     * @param data ABI-encoded string representing the session id6.
     */
    function onERC20Received(
        address, /*sender*/
        address from,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        require(_msgSender() == address(revvToken), "Sessions: wrong token");
        uint256 price = sessionPrice;
        require(price != 0, "Sessions: price not set");
        uint256 userFreeSessions = freeSessionsUsed[from];
        if (userFreeSessions < freeSessions) {
            require(value == 0, "Sessions: session is free");
            freeSessionsUsed[from] = userFreeSessions + 1; // cannot overflow as user free sessions can never reach max uint256
        } else {
            require(value == price, "Sessions: wrong price");
            revvToken.wrappedTransfer(payoutWallet, value);
        }

        emit Admission(from, abi.decode(data, (string)), value);

        return _ERC20_RECEIVED;
    }

    // Meta-transactions

    function _msgSender() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (address payable) {
        return UsingUniversalForwarding._msgSender();
    }

    function _msgData() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (bytes memory ret) {
        return UsingUniversalForwarding._msgData();
    }
}
