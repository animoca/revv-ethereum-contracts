/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get} = deployments;
  const {deployer} = await getNamedAccounts();
  const forwarderRegistry = await get('ForwarderRegistry');
  await deploy('PolygonREVVMotorsportShard', {
    from: deployer,
    args: [
      forwarderRegistry.address, // forwarderRegistry
      '0xb991E39a401136348Dee93C75143B159FabF483f', // childChainManager on Amoy
    ],
    log: true,
  });
};
module.exports.tags = ['PolygonREVVMotorsportShard'];
module.exports.dependencies = ['ForwarderRegistry'];
