/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get} = deployments;
  const {deployer} = await getNamedAccounts();
  const forwarderRegistry = await get('ForwarderRegistry');
  await deploy('REVVRacingNFT', {
    from: deployer,
    args: [
      '0x000000000000AAeB6D7670E522A718067333cd4E', // IOperatorFilterRegistry deployed on all chains
      forwarderRegistry.address, // IForwarderRegistry
    ],
    log: true,
  });
};
module.exports.tags = ['REVVRacingNFT'];
module.exports.dependencies = ['ForwarderRegistry'];
