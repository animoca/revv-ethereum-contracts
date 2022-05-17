const merge = require('lodash.merge');

require('@animoca/ethereum-contracts/hardhat-plugins');

module.exports = merge(require('@animoca/ethereum-contracts/hardhat-config'), require('./hardhat-config'));
