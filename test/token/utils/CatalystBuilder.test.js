const {artifacts, accounts} = require('hardhat');
const {expectRevert, expectEvent} = require('@openzeppelin/test-helpers');
const interfaces20 = require('@animoca/ethereum-contracts-assets/src/interfaces/ERC165/ERC20');
const {constants, behaviors} = require('@animoca/ethereum-contracts-core');
const {ZeroAddress, EmptyByte} = constants;

describe('REVVRacingCatalystBuilder', function () {
  const [deployer, other] = accounts;

  beforeEach(async function () {
    const registry = await artifacts.require('ForwarderRegistry').new({from: deployer});
    this.shards = await artifacts.require('REVVMotorsportShard').new(registry.address, {from: deployer});
    this.catalysts = await artifacts.require('REVVRacingCatalyst').new(registry.address, {from: deployer});
    this.contract = await artifacts.require('REVVRacingCatalystBuilder').new(this.shards.address, this.catalysts.address, {from: deployer});
    await this.catalysts.addMinter(this.contract.address, {from: deployer});
  });

  describe('onERC20Received()', function () {
    it('reverts if not sent by the shards contract', async function () {
      await expectRevert(this.contract.onERC20Received(ZeroAddress, ZeroAddress, 0, EmptyByte, {from: deployer}), 'CatalystBuilder: wrong sender');
    });

    it('reverts if the conversion rate has not been set', async function () {
      await expectRevert(this.shards.safeTransfer(this.contract.address, 0, EmptyByte, {from: deployer}), 'CatalystBuilder: rate not set');
    });

    context('when successful', function () {
      const amount = 10;
      beforeEach(async function () {
        await this.contract.setConversionRate(1, {from: deployer});
        await this.shards.mint(deployer, amount, {from: deployer});
        this.receipt = await this.shards.safeTransfer(this.contract.address, amount, EmptyByte, {from: deployer});
      });

      it('burns the shards', async function () {
        await expectEvent.inTransaction(this.receipt.tx, this.shards, 'Transfer', {
          _from: this.contract.address,
          _to: ZeroAddress,
          _value: amount,
        });
      });

      it('mints the catalysts', async function () {
        await expectEvent.inTransaction(this.receipt.tx, this.catalysts, 'Transfer', {
          _from: ZeroAddress,
          _to: deployer,
          _value: amount,
        });
      });
    });
  });

  describe('setConversionRate()', function () {
    const conversionRate = 1;
    it('reverts if not sent by a minter', async function () {
      await expectRevert(this.contract.setConversionRate(conversionRate, {from: other}), 'MinterRole: not a Minter');
    });

    it('emits a ConversionRateUpdated event', async function () {
      const receipt = await this.contract.setConversionRate(1, {from: deployer});
      expectEvent(receipt, 'ConversionRateUpdated', {conversionRate});
    });
  });

  behaviors.shouldSupportInterfaces([interfaces20.ERC20Receiver]);
});
