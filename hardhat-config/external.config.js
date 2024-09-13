/**
 * @type {import ('hardhat/types').HardhatConfig}
 */
module.exports = {
  external: {
    contracts: [
      {
        artifacts: ['artifacts_previous/v6.3', 'artifacts_previous/v5.1', 'artifacts_previous/v4', 'artifacts_previous/v3', 'artifacts_previous/v1'],
      },
      {
        // import artifacts and deploy script from ethereum-universal-forwarder
        artifacts: 'node_modules/ethereum-universal-forwarder/export/artifacts',
        deploy: 'node_modules/ethereum-universal-forwarder/export/deploy',
      },
      {
        artifacts: 'node_modules/@animoca/ethereum-contracts/artifacts',
      },
    ],
  },
};
