module.exports = {
  external: {
    contracts: [
      {
        artifacts: ['artifacts_previous/v4'],
      },
      {
        artifacts: 'node_modules/@animoca/ethereum-contracts/artifacts',
      },
    ],
  },
};
