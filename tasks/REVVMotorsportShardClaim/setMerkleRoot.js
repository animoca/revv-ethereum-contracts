const {task} = require('hardhat/config');

task('REVVMotorsportShardClaim:setMerkleRoot', 'Set the provided merkle root on the REVV Motorsport Shard claim contract')
  .addParam('merkleRoot', 'The merkle root to set')
  .setAction(async ({merkleRoot}, {deployments, getNamedAccounts}) => {
    const {deployer} = await getNamedAccounts();
    console.log('Using signer wallet:', deployer);

    const contract = await deployments.get('REVVMotorsportShardClaim');
    console.log('Using REVVMotorsportShardClaim at', contract.address);

    console.log('Setting merkle root to', merkleRoot, '...');
    const tx = await deployments.execute('REVVMotorsportShardClaim', {from: deployer, log: true}, 'setMerkleRoot', merkleRoot);
    console.log('Done in tx', tx.transactionHash);
  });
