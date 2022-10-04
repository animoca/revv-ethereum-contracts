# Changelog

## 6.0.0

### Breaking changes

- Migrated to the new core library `@animoca/ethereum-contracts`, replacing `@animoca/ethereum-contracts-core`.
- Moved the old artifacts folders under `artifacts_previous`.
- Revisited the fusion mechanism.

### New features

- Added `REVVMotorsportVouchers` contract.
- Added `REVVMotorsportShard` contract.
- Added `REVVRacingCatalyst` contract.
- Added `REVVRacingNFT` contract.

## 5.1.0

### Chores

- Removed fusion and catalyst building setup, to be added back in next major version.

## 5.0.1

### Bugfixes

- Renamed `REVVMotorsportCatalyst` to `REVVRacingCatalyst`.

## 5.0.0

### New features

- Added new contracts `REVVMotorsportShard.sol`, `REVVMotorsportCatalyst.sol`, `PolygonREVVMotorsportShard.sol` and `PolygonREVVMotorsportCatalyst.sol`.
- Added contract `CatalystBuilder.sol` (WIP).
- Added fusion system design (WIP).

## 4.0.0

### Breaking Changes

- Moved files related to `PolygonREVV`, `SessionsManager` and `REVVMotorsportInventory` to `_v3` folders.
- Updated dependencies to `@animoca/ethereum-contracts-core@1.1.2` and `@animoca/ethereum-contracts-assets@2.0.0`.

### New features

- Added new contract `REVVRacingInventory` to migrate implementation from existing `REVVMotorsportInventory`.
- Added new contract `REVVxUndoneVouchersRedeemer.sol`.
- Added markdown linting.

## 3.3.0

### New features

- Added `SessionsManager.sol` to manage REVV Racing game sessions.

## 3.2.1

### Fixes

- Updated dependencies for yarn audit fixes and warning messages during tests.

## 3.2.0

### Breaking Changes

- Updated dependencies versions: `@animoca/ethereum-contracts-core@1.1.0` and `@animoca/ethereum-contracts-assets@1.1.1`.

## 3.1.0

### Breaking changes

- Updated contract name, name and symbol from FormulaREVVInventory to REVVMotorsportInventory.

## 3.0.0

### Breaking changes

- Migrated to `@animoca/ethereum-contracts-core@1.0.1`.

### New features

- Added `PolygonREVV.sol`, the Polygon L2 bridged version of REVV.
- Added `FormulaREVVInventory.sol`, the ERC1155721 assets contract for Formula REVV.

## 2.1.0

- Added `FixedOrderSandNftSale.sol`, a sale contract to handle the purchases of Sandbox NFTs via REDP.

## 2.0.0

- Migration to `@animoca/hardhat-bootstrap`, `@animoca/ethereum-contracts-assets_inventory@8.0.0`, `@animoca/ethereum-contracts-erc20_base@4.0.0` and `@animoca/ethereum-contracts-core_library@5.0.0`.

## 1.0.0

- Initial release.
