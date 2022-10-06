const {mergeConfigs} = require('@animoca/ethereum-contracts/src/config');

require('@animoca/ethereum-contracts/hardhat-plugins');

module.exports = mergeConfigs(require('@animoca/ethereum-contracts/hardhat-config'), require('./hardhat-config'));
