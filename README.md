# REVV Solidity Contracts

[![Coverage Status](https://codecov.io/gh/animoca/revv-ethereum-contracts/graph/badge.svg)](https://codecov.io/gh/animoca/revv-ethereum-contracts)

This project contains the solidity contracts for the REVV project.

## Audits

| Date       | Scope                                    | Commit                                                                                                                                       | Package version                                                                 | Auditor                                | Report                                                                                                                      |
| ---------- | ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- | -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| 14/11/2022 | REVVMotorsportShard & REVVRacingCatalyst | [0ffc859794d3cd70928559fa03e48aeea8d7c36b](https://github.com/animoca/revv-ethereum-contracts/tree/0ffc859794d3cd70928559fa03e48aeea8d7c36b) | [6.0.0](https://www.npmjs.com/package/@animoca/revv-ethereum-contracts/v/6.0.0) | [Halborn](https://https://halborn.com) | [link](/audit/Animoca_SHRD_CATA_ERC20_Tokens_Polygon_ERC20_Bridging_Smart_Contract_Security_Audit_Report_Halborn_Final.pdf) |

## Solidity contracts

Only the contracts corresponding to the features developed for the current version of the module are present. For previously developed contracts, check out older commits / package versions.

## Compilation artifacts

The compilation artifacts, including the debug information, are available in the `artifacts` folder, both in the git repository and the release packages. The artifacts for the previous versions of the module are also available in the `artifacts_previous` folder. These artifacts can be imported in dependents projects and used in tests or migration scripts with the following hardhat configuration:

```javascript
  external: {
    contracts: [
      {
        artifacts: 'node_modules/@animoca/revv-ethereum-contracts/artifacts',
      },
      {
        artifacts: 'node_modules/@animoca/revv-ethereum-contracts/artifacts_previous',
      },
    ],
  },
```

## Installation

To install the module in your project, add it as an npm dependency:

```bash
yarn add -D @animoca/revv-ethereum-contracts hardhat
```

or

```bash
npm add --save-dev @animoca/revv-ethereum-contracts hardhat
```

## Development

Install the dependencies:

```bash
yarn
```

Compile the contracts:

```bash
yarn compile
```

Run the tests:

```bash
yarn test
```

Run the tests (parallel mode):

```bash
yarn test-p
```

Run the coverage tests:

```bash
yarn coverage
```

Run the full pipeline (should be run before commiting code):

```bash
yarn run-all
```

See `package.json` for additional commands.

Note: this repository uses git lfs: the module should be installed before pushing changes.
