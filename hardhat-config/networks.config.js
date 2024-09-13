/**
 * @type {import ('hardhat/types').HardhatConfig}
 */
module.exports = {
  networks: {
    sepolia: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/' + process.env.ALCHEMY_API_KEY,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || '0x0000000000000000000000000000000000000000000000000000000000000000', // deployer
      ],
      verify: {
        etherscan: {
          apiKey: process.env.ETHERSCAN_API_KEY,
        },
      },
    },
    amoy: {
      url: 'https://polygon-amoy.g.alchemy.com/v2/' + process.env.ALCHEMY_API_KEY,
      accounts: [
        process.env.DEPLOYER_PRIVATE_KEY || '0x0000000000000000000000000000000000000000000000000000000000000000', // deployer
      ],
      gasPrice: 50000000000, // forced to 50 gwei, see https://gasstation.polygon.technology/amoy
      verify: {
        etherscan: {
          apiUrl: 'https://api-amoy.polygonscan.com/',
          apiKey: process.env.POLYGONSCAN_API_KEY,
        },
      },
    },
  },
};
