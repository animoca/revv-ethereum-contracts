module.exports = function (chainId, verifyingContract, forwarder, approved = true, nonce = 0) {
  return {
    domain: {
      name: 'ForwarderRegistry',
      chainId,
      verifyingContract,
    },
    primaryType: 'ApproveForwarder',
    message: {
      forwarder,
      approved,
      nonce,
    },
    types: {
      ApproveForwarder: [
        {
          name: 'forwarder',
          type: 'address',
        },
        {
          name: 'approved',
          type: 'bool',
        },
        {
          name: 'nonce',
          type: 'uint256',
        },
      ],
    },
  };
};
