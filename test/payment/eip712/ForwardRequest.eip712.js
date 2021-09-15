/**
 * @param {int} chainId
 * @param {string} verifyingContract
 * @param {{from:string,to:string,value:string,gas:string,nonce:int,data:string}} forwarderRequest
 * @returns {object}
 */
module.exports = function (chainId, verifyingContract, forwarderRequest) {
  return {
    domain: {
      name: 'MinimalForwarder',
      version: '0.0.1',
      chainId,
      verifyingContract,
    },
    primaryType: 'ForwardRequest',
    message: {
      ...forwarderRequest,
    },
    types: {
      ForwardRequest: [
        {
          name: 'from',
          type: 'address',
        },
        {
          name: 'to',
          type: 'address',
        },
        {
          name: 'value',
          type: 'uint256',
        },
        {
          name: 'gas',
          type: 'uint256',
        },
        {
          name: 'nonce',
          type: 'uint256',
        },
        {
          name: 'data',
          type: 'bytes',
        },
      ],
      EIP712Domain: [
        {
          name: 'name',
          type: 'string',
        },
        {
          name: 'version',
          type: 'string',
        },
        {
          name: 'chainId',
          type: 'uint256',
        },
        {
          name: 'verifyingContract',
          type: 'address',
        },
      ],
    },
  };
};
