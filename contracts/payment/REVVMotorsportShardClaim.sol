// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import {IERC20Mintable} from "@animoca/ethereum-contracts/contracts/token/ERC20/interfaces/IERC20Mintable.sol";
import {CumulativeMerkleClaim} from "@animoca/ethereum-contracts/contracts/payment/CumulativeMerkleClaim.sol";

contract REVVMotorsportShardClaim is CumulativeMerkleClaim {
    IERC20Mintable public immutable shard;

    constructor(IERC20Mintable shard_) {
        shard = shard_;
    }

    function _distributePayout(address claimer, bytes calldata claimData) internal virtual override {
        uint256 amount = abi.decode(claimData, (uint256));
        shard.mint(claimer, amount);
    }
}
