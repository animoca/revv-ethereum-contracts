const {ethers} = require('hardhat');
const {expect} = require('chai');
const {constants} = ethers;
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');
const {deployContract} = require('@animoca/ethereum-contract-helpers/src/test/deploy');
const {loadFixture} = require('@animoca/ethereum-contract-helpers/src/test/fixtures');
const {getForwarderRegistryAddress} = require('@animoca/ethereum-contracts/test/helpers/registries');

describe('REVVMotorsportShardClaim', function () {
  let other;

  before(async function () {
    [deployer, claimer1, claimer2, claimer3, claimer4, other] = await ethers.getSigners();
  });

  const fixture = async function () {
    const forwarderRegistryAddress = await getForwarderRegistryAddress();
    this.shards = await deployContract('REVVMotorsportShard', forwarderRegistryAddress);
    this.contract = await deployContract('REVVMotorsportShardClaim', this.shards.address);
    await this.shards.grantRole(await this.shards.MINTER_ROLE(), this.contract.address);
  };

  beforeEach(async function () {
    await loadFixture(fixture, this);
  });

  context('claimPayout(address,bytes,bytes32[])', function () {
    beforeEach(async function () {
      this.nextNonce = (await this.contract.nonce()).add(constants.One);

      this.elements = [
        {
          claimer: claimer1.address,
          amount: 1,
        },
        {
          claimer: claimer2.address,
          amount: 2,
        },
        {
          claimer: claimer3.address,
          amount: 3,
        },
        {
          claimer: claimer4.address,
          amount: 4,
        },
      ];
      this.leaves = this.elements.map((el) =>
        ethers.utils.solidityPack(
          ['address', 'bytes', 'uint256'],
          [el.claimer, ethers.utils.defaultAbiCoder.encode(['uint256'], [el.amount]), this.nextNonce]
        )
      );
      this.tree = new MerkleTree(this.leaves, keccak256, {hashLeaves: true, sortPairs: true});
      this.root = this.tree.getHexRoot();
      await this.contract.setMerkleRoot(this.root);
      await this.contract.unpause();
    });
    it('mints the SHRD', async function () {
      const claimData = ethers.utils.defaultAbiCoder.encode(['uint256'], [this.elements[0].amount]);
      await expect(this.contract.claimPayout(this.elements[0].claimer, claimData, this.tree.getHexProof(keccak256(this.leaves[0]))))
        .to.emit(this.shards, 'Transfer')
        .withArgs(constants.AddressZero, this.elements[0].claimer, this.elements[0].amount);
    });
  });
});
