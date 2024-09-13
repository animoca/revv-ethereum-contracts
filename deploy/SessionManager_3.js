const {BigNumber} = require('@ethersproject/bignumber');

const deploymentName = 'SessionsManager_3';
const sessionPrice = BigNumber.from(3).mul(BigNumber.from(10).pow(18)); // 3 REVV
/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy, get, execute, read} = deployments;
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
  /**
   * @type {import ('@ethersproject/bignumber').BigNumber}
   */
  const actualSessionPrice = await read(deploymentName, {}, 'sessionPrice');
  if (!actualSessionPrice.eq(sessionPrice))
    await execute(
      deploymentName,
      {
        from: deployer,
        log: true,
      },
      'setSessionPrice',
      sessionPrice
    );
};
module.exports.tags = ['SessionsManager', deploymentName];
module.exports.dependencies = ['PolygonREVV'];
