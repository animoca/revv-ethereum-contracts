const {ethers} = require('hardhat');
const {EmptyByte, ZeroAddress} = require('@animoca/ethereum-contracts/src/constants');
const {getForwarderRegistryAddress} = require('@animoca/ethereum-contracts/test/helpers/run');
const {loadFixture} = require('@animoca/ethereum-contracts/test/helpers/fixtures');
const {shouldSupportInterfaces} = require('@animoca/ethereum-contracts/test/behaviors');

describe('REVVRacingCatalystBuilder', function () {
  let deployer, other;

  before(async function () {
    [deployer, other, payoutWallet] = await ethers.getSigners();
  });

  const fixture = async function () {
    const forwarderRegistryAddress = await getForwarderRegistryAddress();

    const REVVMotorsportShard = await ethers.getContractFactory('REVVMotorsportShard');
    this.shards = await REVVMotorsportShard.deploy(forwarderRegistryAddress);
    this.shards.deployed();

    const REVVRacingCatalyst = await ethers.getContractFactory('REVVRacingCatalyst');
    this.catalysts = await REVVRacingCatalyst.deploy(forwarderRegistryAddress);
    this.catalysts.deployed();

    const REVVRacingCatalystBuilder = await ethers.getContractFactory('REVVRacingCatalystBuilder');
    this.contract = await REVVRacingCatalystBuilder.deploy(this.shards.address, this.catalysts.address);
    this.contract.deployed();

    this.contract.grantRole(await this.contract.RATE_MANAGER_ROLE(), deployer.address);

    await this.catalysts.addMinter(this.contract.address);
  };

  beforeEach(async function () {
    await loadFixture(fixture, this);
  });

  describe('onERC20Received()', function () {
    it('reverts if not sent by the shards contract', async function () {
      await expect(this.contract.onERC20Received(ZeroAddress, ZeroAddress, 0, EmptyByte)).to.be.revertedWith('CatalystBuilder: wrong sender');
    });

    it('reverts if the conversion rate has not been set', async function () {
      await expect(this.shards.safeTransfer(this.contract.address, 0, EmptyByte)).to.be.revertedWith('CatalystBuilder: rate not set');
    });

    context('when successful', function () {
      const amount = 10;
      beforeEach(async function () {
        await this.contract.setConversionRate(1);
        await this.shards.mint(deployer.address, amount);
        this.receipt = await this.shards.safeTransfer(this.contract.address, amount, EmptyByte);
      });

      it('burns the shards', async function () {
        await expect(this.receipt).to.emit(this.shards, 'Transfer').withArgs(this.contract.address, ZeroAddress, amount);
      });

      it('mints the catalysts', async function () {
        await expect(this.receipt).to.emit(this.catalysts, 'Transfer').withArgs(ZeroAddress, deployer.address, amount);
      });
    });
  });

  describe('setConversionRate()', function () {
    const conversionRate = 1;
    it('reverts if not sent by a minter', async function () {
      await expect(this.contract.connect(other).setConversionRate(conversionRate)).to.be.revertedWith("AccessControl: missing 'RATE_MANAGER' role");
    });

    it('emits a ConversionRateUpdated event', async function () {
      const receipt = await this.contract.setConversionRate(1);
      await expect(receipt).to.emit(this.contract, 'ConversionRateUpdated').withArgs(conversionRate);
    });
  });

  shouldSupportInterfaces(['IERC20Receiver']);
});
