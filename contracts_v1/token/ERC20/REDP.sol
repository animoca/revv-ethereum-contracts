// SPDX-License-Identifier: MIT

pragma solidity 0.6.8;

import "@animoca/ethereum-contracts-erc20_base/contracts/token/ERC20/ERC20WithOperators.sol";
import "@animoca/ethereum-contracts-core-3/contracts/access/MinterRole.sol";

/**
 * @title REDP
 */
contract REDP is ERC20WithOperators, MinterRole {
    // solhint-disable-next-line const-name-snakecase
    string public constant override name = "REDP";
    // solhint-disable-next-line const-name-snakecase
    string public constant override symbol = "REDP";
    // solhint-disable-next-line const-name-snakecase
    uint8 public constant override decimals = 18;

    function mint(address holder, uint256 amount) public onlyMinter {
        _mint(holder, amount);
    }

    function batchMint(address[] memory holders, uint256[] memory amounts) public onlyMinter {
        require(holders.length == amounts.length, "REDP: inconsistent arrays");
        for (uint256 i = 0; i < holders.length; ++i) {
            _mint(holders[i], amounts[i]);
        }
    }

    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "REDP: not enough allowance");

        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
}
