const {ethers} = require('hardhat');
const {constants} = ethers;
const {loadFixture} = require('@animoca/ethereum-contract-helpers/src/test/fixtures');
const {deployContract} = require('@animoca/ethereum-contract-helpers/src/test/deploy');
const {getForwarderRegistryAddress} = require('@animoca/ethereum-contracts/test/helpers/registries');
const {supportsInterfaces} = require('@animoca/ethereum-contracts/test/behaviors');

describe('REVVRacingCatalystBuilder', function () {
  let deployer, other;

  before(async function () {
    [deployer, other, payoutWallet] = await ethers.getSigners();
  });

  const fixture = async function () {
    const forwarderRegistryAddress = await getForwarderRegistryAddress();

    this.shards = await deployContract('REVVMotorsportShard', forwarderRegistryAddress);
    this.catalysts = await deployContract('REVVRacingCatalyst', forwarderRegistryAddress);
    this.contract = await deployContract('REVVRacingCatalystBuilder', this.shards.address, this.catalysts.address);

    await this.contract.grantRole(await this.contract.RATE_MANAGER_ROLE(), deployer.address);
    await this.shards.grantRole(await this.shards.MINTER_ROLE(), deployer.address);
    await this.catalysts.grantRole(await this.catalysts.MINTER_ROLE(), this.contract.address);
  };

  beforeEach(async function () {
    await loadFixture(fixture, this);
  });

  describe('onERC20Received()', function () {
    it('reverts if not sent by the shards contract', async function () {
      await expect(this.contract.onERC20Received(constants.AddressZero, constants.AddressZero, 0, '0x')).to.be.revertedWith(
        'CatalystBuilder: wrong sender'
      );
    });

    it('reverts if the conversion rate has not been set', async function () {
      await expect(this.shards.safeTransfer(this.contract.address, 0, '0x')).to.be.revertedWith('CatalystBuilder: rate not set');
    });

    context('when successful', function () {
      const amount = 10;
      beforeEach(async function () {
        await this.contract.setConversionRate(1);
        await this.shards.mint(deployer.address, amount);
        this.receipt = await this.shards.safeTransfer(this.contract.address, amount, '0x');
      });

      it('burns the shards', async function () {
        await expect(this.receipt).to.emit(this.shards, 'Transfer').withArgs(this.contract.address, constants.AddressZero, amount);
      });

      it('mints the catalysts', async function () {
        await expect(this.receipt).to.emit(this.catalysts, 'Transfer').withArgs(constants.AddressZero, deployer.address, amount);
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

  supportsInterfaces(['IERC20Receiver']);
});
