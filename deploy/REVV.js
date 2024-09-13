/**
 * @param {import ('hardhat/types').HardhatRuntimeEnvironment}
 */
module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();
  await deploy('REVV', {
    from: deployer,
    args: [
      [deployer], // holders
      ['4400000000000000000000000000'], // amounts
    ],
    log: true,
  });
};
module.exports.tags = ['REVV'];
