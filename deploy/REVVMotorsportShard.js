/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get} = deployments;
  const {deployer} = await getNamedAccounts();
  const forwarderRegistry = await get('ForwarderRegistry');
  await deploy('REVVMotorsportShard', {
    from: deployer,
    args: [
      forwarderRegistry.address, // forwarderRegistry
    ],
    log: true,
  });
};
module.exports.tags = ['REVVMotorsportShard'];
module.exports.dependencies = ['ForwarderRegistry'];
