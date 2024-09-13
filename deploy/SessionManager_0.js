const {BigNumber} = require('@ethersproject/bignumber');

const deploymentName = 'SessionsManager_0';
const freeSessions = BigNumber.from('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'); // max uint256
/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get, execute} = deployments;
  const {deployer, payoutWallet} = await getNamedAccounts();
  const revvToken = await get('PolygonREVV');
  await deploy(deploymentName, {
    contract: 'SessionsManager',
    from: deployer,
    args: [
      revvToken.address, // revvToken
      payoutWallet, // payoutWallet
    ],
    log: true,
  });
  try {
    await execute(
      deploymentName,
      {
        from: deployer,
        log: true,
      },
      'addFreeSessions',
      freeSessions
    );
  } catch (e) {
    // check if error is free sessions already added
    if (!e.message.includes('Sessions: sessions overflow')) throw e;
  }
};
module.exports.tags = ['SessionsManager', deploymentName];
module.exports.dependencies = ['PolygonREVV'];
