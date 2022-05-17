module.exports = {
  external: {
    contracts: [
      {
        artifacts: 'artifacts_previous/v4',
      },
      {
        artifacts: 'artifacts_previous/v5',
      },
      {
        artifacts: 'node_modules/@animoca/ethereum-contracts/artifacts',
      },
    ],
  },
};
