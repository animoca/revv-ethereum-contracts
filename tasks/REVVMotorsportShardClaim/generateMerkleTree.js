const {task} = require('hardhat/config');
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');
const {readFile} = require('fs/promises');

task('REVVMotorsportShardClaim:generateMerkleTree', 'Generate a merkle tree for the REVV Motorsport Shard claim')
  .addParam('file', 'The CSV file path to read the claimers and amounts from')
  .setAction(async ({file}, {ethers, deployments}) => {
    const contract = await deployments.get('REVVMotorsportShardClaim');
    console.log('Using REVVMotorsportShardClaim at', contract.address);

    const nonce = await deployments.read('REVVMotorsportShardClaim', 'nonce');
    console.log('contract last nonce', nonce.toString());
    const nextNonce = nonce.add(ethers.constants.One);

    // read CSV file and parse it
    const elements = (await readFile(file))
      .toString()
      .split('\n') // split by line
      .slice(1) // remove first line
      .filter(Boolean) // remove empty lines
      .map((line) => line.split(',')) // split by comma
      .map(([claimer, amount]) => ({claimer, amount})); // map to object
    console.log('elements', elements);

    const leaves = elements.map((el) =>
      ethers.utils.solidityPack(
        ['address', 'bytes', 'uint256'],
        [el.claimer, ethers.utils.defaultAbiCoder.encode(['uint256'], [el.amount]), nextNonce]
      )
    );
    const tree = new MerkleTree(leaves, keccak256, {hashLeaves: true, sortPairs: true});
    console.log('tree', MerkleTree.marshalTree(tree));
  });
