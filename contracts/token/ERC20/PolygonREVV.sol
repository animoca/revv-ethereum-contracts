// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {ManagedIdentity, Ownable, Recoverable, RecoverableERC20} from "@animoca/ethereum-contracts-core-1.0.1/contracts/utils/Recoverable.sol";
import {ChildERC20} from "@animoca/ethereum-contracts-assets-1.0.2/contracts/token/ERC20/ChildERC20.sol";
import {IForwarderRegistry, UsingUniversalForwarding} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/UsingUniversalForwarding.sol";

contract PolygonREVV is Recoverable, UsingUniversalForwarding, ChildERC20 {
    uint256 public escrowed;

    constructor(
        uint256 supply,
        IForwarderRegistry forwarderRegistry,
        address universalForwarder
    ) ChildERC20("REVV", "REVV", 18, "") UsingUniversalForwarding(forwarderRegistry, universalForwarder) Ownable(msg.sender) {
        _mint(address(this), supply);
        escrowed = supply;
    }

    function setTokenURI(string memory tokenURI_) external {
        _requireOwnership(_msgSender());
        _tokenURI = tokenURI_;
    }

    function deposit(address user, bytes calldata depositData) public virtual override {
        _requireDepositorRole(_msgSender());
        uint256 amount = abi.decode(depositData, (uint256));
        escrowed -= amount;
        _transfer(address(this), user, amount);
    }

    function withdraw(uint256 amount) public virtual override {
        escrowed += amount;
        super.withdraw(amount);
    }

    function onERC20Received(
        address operator,
        address from,
        uint256 amount,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        escrowed += amount;
        return super.onERC20Received(operator, from, amount, data);
    }

    function recoverERC20s(
        address[] calldata accounts,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external virtual override {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == tokens.length && length == amounts.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            if (token == address(this)) {
                uint256 recoverable = _balances[address(this)] - escrowed;
                require(amount <= recoverable, "Recov: insufficient balance");
            }
            require(RecoverableERC20(token).transfer(accounts[i], amount), "Recov: transfer failed");
        }
    }

    function _msgSender() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (address payable) {
        return UsingUniversalForwarding._msgSender();
    }

    function _msgData() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (bytes memory ret) {
        return UsingUniversalForwarding._msgData();
    }
}
