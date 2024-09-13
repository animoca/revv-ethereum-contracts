/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get, execute, read} = deployments;
  const {deployer} = await getNamedAccounts();
  const polygonREVVMotorsportShard = await get('PolygonREVVMotorsportShard');
  const deployed = await deploy('REVVMotorsportShardClaim', {
    from: deployer,
    args: [
      polygonREVVMotorsportShard.address, // polygonREVVMotorsportShard
    ],
    log: true,
  });

  // grant minter role on PolygonREVVMotorsportShard to REVVMotorsportShardClaim if needed
  const isMinter = await read('PolygonREVVMotorsportShard', 'isMinter', deployed.address);
  if (!isMinter) {
    await execute('PolygonREVVMotorsportShard', {from: deployer, log: true}, 'addMinter', deployed.address);
  }
};
module.exports.tags = ['REVVMotorsportShardClaim'];
module.exports.dependencies = ['PolygonREVVMotorsportShard'];
