const {artifacts, accounts, web3} = require('hardhat');
const {BN, expectRevert, expectEvent} = require('@openzeppelin/test-helpers');
const interfaces165 = require('@animoca/ethereum-contracts-core/src/interfaces/ERC165');
const {constants, behaviors} = require('@animoca/ethereum-contracts-core');
const {ZeroAddress, EmptyByte, MaxUInt256} = constants;
const {createFixtureLoader} = require('@animoca/ethereum-contracts-core/test/utils/fixture');

const [deployer, participant, payoutWallet, yard, other] = accounts;

const blueprintA = {
  blueprintId: 1,
  spentTokenMask: new BN('ff00000000000000000000000000000000000000000000000000000000000000', 'hex'),
  deliveredTokenMask: new BN('f000000000000000000000000000000000000000000000000000000000000000', 'hex'),
  catalystCost: 1,
  revvCost: 1,
};

const blueprintACar1 = blueprintA.spentTokenMask.or(new BN('1'));

const blueprintB = {
  blueprintId: 2,
  spentTokenMask1: new BN('fff0000000000000000000000000000000000000000000000000000000000000', 'hex'),
  spentTokenMask2: new BN('ffe0000000000000000000000000000000000000000000000000000000000000', 'hex'),
  deliveredTokenMask: new BN('f000000000000000000000000000000000000000000000000000000000000000', 'hex'),
  catalystCost: 2,
  revvCost: 2,
};

const blueprintBCar1 = blueprintB.spentTokenMask1.or(new BN('1'));
const blueprintBCar2 = blueprintB.spentTokenMask2.or(new BN('1'));

const otherCar1 = new BN('feffff0000000000000000000000000000000000000000000000000000000001', 'hex');
const otherCar2 = new BN('fdffff0000000000000000000000000000000000000000000000000000000001', 'hex');

describe('Fusion', function () {
  const fixtureLoader = createFixtureLoader(accounts, web3.eth.currentProvider);

  const fixture = async function () {
    const registry = await artifacts.require('ForwarderRegistry').new({from: deployer});

    this.cars = await artifacts.require('REVVRacingInventory').new(registry.address, ZeroAddress, {from: deployer});
    await this.cars.batchMint(participant, [blueprintACar1, blueprintBCar1, blueprintBCar2, otherCar1, otherCar2], {from: deployer});

    this.catalysts = await artifacts.require('REVVMotorsportCatalystMock').new([participant], [100], registry.address, {from: deployer});
    this.revv = await artifacts.require('ERC20Mock').new([participant], [100], registry.address, ZeroAddress, {from: deployer});
    this.counters = await artifacts.require('ChassisCounters').new({from: deployer});

    this.proxy = await artifacts
      .require('FusionProxy')
      .new(this.cars.address, this.catalysts.address, this.revv.address, this.counters.address, payoutWallet, yard, {from: deployer});
    await this.counters.addMinter(this.proxy.address, {from: deployer});
    await this.cars.addMinter(this.proxy.address, {from: deployer});

    this.blueprintA = await artifacts
      .require('BlueprintA')
      .new(blueprintA.spentTokenMask, blueprintA.deliveredTokenMask, blueprintA.catalystCost, blueprintA.revvCost, {from: deployer});
    await this.proxy.setBlueprint(blueprintA.blueprintId, this.blueprintA.address, {from: deployer});

    this.blueprintB = await artifacts
      .require('BlueprintB')
      .new(blueprintB.spentTokenMask1, blueprintB.spentTokenMask2, blueprintB.deliveredTokenMask, blueprintB.catalystCost, blueprintB.revvCost, {
        from: deployer,
      });
    await this.proxy.setBlueprint(blueprintB.blueprintId, this.blueprintB.address, {from: deployer});

    this.contract = this.proxy;
  };

  beforeEach(async function () {
    await fixtureLoader(fixture, this);
  });

  describe('FusionProxy', function () {
    describe('constructor()', function () {
      it('sets the deployer as contract owner', async function () {
        (await this.proxy.owner()).should.be.equal(deployer);
      });

      it('emits an OwnershipTransferred event', async function () {
        await expectEvent.inConstruction(this.proxy, 'OwnershipTransferred', {
          previousOwner: ZeroAddress,
          newOwner: deployer,
        });
      });

      it('sets the cars address', async function () {
        (await this.proxy.cars()).should.be.equal(this.cars.address);
      });

      it('sets the catalysts address', async function () {
        (await this.proxy.catalysts()).should.be.equal(this.catalysts.address);
      });

      it('sets the REVV address', async function () {
        (await this.proxy.revv()).should.be.equal(this.revv.address);
      });

      it('sets the counters address', async function () {
        (await this.proxy.counters()).should.be.equal(this.counters.address);
      });

      it('sets the payout wallet', async function () {
        (await this.proxy.payoutWallet()).should.be.equal(payoutWallet);
      });

      it('sets the yard address', async function () {
        (await this.proxy.yard()).should.be.equal(yard);
      });
    });

    describe('setBlueprint(uint256,address)', function () {
      it('reverts if not sent by the contract owner', async function () {
        await expectRevert(this.proxy.setBlueprint(0, ZeroAddress, {from: participant}), 'Fusion: not the contract owner');
      });

      it('sets the blueprint', async function () {
        await this.proxy.setBlueprint(0, other, {from: deployer});
        (await this.proxy.blueprint(0)).should.be.equal(other);
      });

      it('sets the blueprint (with a zero address arg)', async function () {
        await this.proxy.setBlueprint(0, ZeroAddress, {from: deployer});
        (await this.proxy.blueprint(0)).should.be.equal(ZeroAddress);
      });
    });

    describe('setPayoutWallet(address)', function () {
      it('reverts if not sent by the contract owner', async function () {
        await expectRevert(this.proxy.setPayoutWallet(participant, {from: participant}), 'Fusion: not the contract owner');
      });

      it('sets the payout wallet', async function () {
        await this.proxy.setPayoutWallet(participant, {from: deployer});
        (await this.proxy.payoutWallet()).should.be.equal(participant);
      });
    });

    describe('transferOwnership()', function () {
      it('reverts if not called by the contract owner', async function () {
        await expectRevert(this.proxy.transferOwnership(other, {from: other}), 'Fusion: not the contract owner');
      });

      context('when successful', function () {
        beforeEach(async function () {
          this.receipt = await this.proxy.transferOwnership(other, {from: deployer});
        });

        it('sets the new address as contract owner', async function () {
          (await this.proxy.owner()).should.be.equal(other);
        });

        it('emits a OwnershipTransferred event', async function () {
          expectEvent(this.receipt, 'OwnershipTransferred', {
            previousOwner: deployer,
            newOwner: other,
          });
        });
      });
    });

    describe('onERC1155Received()', function () {
      it('reverts if the blueprint is not set', async function () {
        await expectRevert.unspecified(
          this.proxy.onERC1155Received(ZeroAddress, ZeroAddress, blueprintACar1, 1, EmptyByte, {
            from: participant,
          })
        );
      });

      it('reverts if the blueprint does not exist', async function () {
        await expectRevert(
          this.proxy.onERC1155Received(ZeroAddress, ZeroAddress, blueprintACar1, 1, web3.eth.abi.encodeParameters(['uint256'], [10]), {
            from: participant,
          }),
          'Fusion: blueprint does not exist'
        );
      });

      it('reverts if not called by the cars contract', async function () {
        await expectRevert(
          this.proxy.onERC1155Received(
            ZeroAddress,
            ZeroAddress,
            blueprintACar1,
            1,
            web3.eth.abi.encodeParameters(['uint256'], [blueprintA.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: wrong sender'
        );
      });

      it('reverts if the blueprint rejects the transfer', async function () {
        await expectRevert(
          this.cars.methods['safeTransferFrom(address,address,uint256,uint256,bytes)'](
            participant,
            this.proxy.address,
            blueprintACar1,
            1,
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: unsupported call'
        );
      });

      it('reverts if the car is of an incorrect type', async function () {
        await this.revv.approve(this.proxy.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.proxy.address, MaxUInt256, {from: participant});
        await expectRevert(
          this.cars.methods['safeTransferFrom(address,address,uint256,uint256,bytes)'](
            participant,
            this.proxy.address,
            otherCar1,
            1,
            web3.eth.abi.encodeParameters(['uint256'], [blueprintA.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: wrong token type'
        );
      });

      context('when successful', function () {
        beforeEach(async function () {
          await this.revv.approve(this.proxy.address, MaxUInt256, {from: participant});
          await this.catalysts.approve(this.proxy.address, MaxUInt256, {from: participant});
          this.receipt = await this.cars.methods['safeTransferFrom(address,address,uint256,uint256,bytes)'](
            participant,
            this.proxy.address,
            blueprintACar1,
            1,
            web3.eth.abi.encodeParameters(['uint256'], [blueprintA.blueprintId]),
            {
              from: participant,
            }
          );
        });

        it('burns the catalysts', async function () {
          await expectEvent.inTransaction(this.receipt.tx, this.catalysts, 'Transfer', {
            _from: participant,
            _to: ZeroAddress,
            _value: blueprintA.catalystCost,
          });
        });

        it('sends the REVV to the payout wallet', async function () {
          await expectEvent.inTransaction(this.receipt.tx, this.revv, 'Transfer', {
            _from: participant,
            _to: payoutWallet,
            _value: blueprintA.revvCost,
          });
        });

        it('moves the spent car to the yard', async function () {
          expectEvent(this.receipt, 'TransferSingle', {
            _operator: this.proxy.address,
            _from: this.proxy.address,
            _to: yard,
            _id: blueprintACar1,
            _value: 1,
          });
        });

        it('mints the new car to the owner', async function () {
          expectEvent(this.receipt, 'TransferSingle', {
            _operator: this.proxy.address,
            _from: ZeroAddress,
            _to: participant,
            _id: blueprintA.deliveredTokenMask.or(new BN('1')),
            _value: 1,
          });
        });
      });
    });

    describe('onERC1155BatchReceived()', function () {
      it('reverts if the blueprint is not set', async function () {
        await expectRevert.unspecified(
          this.proxy.onERC1155BatchReceived(ZeroAddress, ZeroAddress, [blueprintBCar1, blueprintBCar2], [1, 1], EmptyByte, {
            from: participant,
          })
        );
      });

      it('reverts if the blueprint does not exist', async function () {
        await expectRevert(
          this.proxy.onERC1155BatchReceived(
            ZeroAddress,
            ZeroAddress,
            [blueprintBCar1, blueprintBCar2],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [10]),
            {
              from: participant,
            }
          ),
          'Fusion: blueprint does not exist'
        );
      });

      it('reverts if not sent by the cars contract', async function () {
        await expectRevert(
          this.proxy.onERC1155BatchReceived(
            ZeroAddress,
            ZeroAddress,
            [blueprintBCar1, blueprintBCar2],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: wrong sender'
        );
      });

      it('reverts if the blueprint rejects the transfer', async function () {
        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.proxy.address,
            [blueprintBCar1, blueprintBCar2],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintA.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: unsupported call'
        );
      });

      it('reverts with an incorrect number of tokens', async function () {
        await this.revv.approve(this.proxy.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.proxy.address, MaxUInt256, {from: participant});

        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.proxy.address,
            [blueprintBCar1],
            [1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: incorrect length'
        );
      });

      it('reverts if the cars are of an incorrect type', async function () {
        await this.revv.approve(this.proxy.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.proxy.address, MaxUInt256, {from: participant});

        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.proxy.address,
            [otherCar1, blueprintBCar1],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: wrong token1 type'
        );

        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.proxy.address,
            [blueprintBCar1, otherCar1],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          ),
          'Fusion: wrong token2 type'
        );
      });

      context('when successful', function () {
        beforeEach(async function () {
          await this.revv.approve(this.proxy.address, MaxUInt256, {from: participant});
          await this.catalysts.approve(this.proxy.address, MaxUInt256, {from: participant});
          this.receipt = await this.cars.safeBatchTransferFrom(
            participant,
            this.proxy.address,
            [blueprintBCar1, blueprintBCar2],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [blueprintB.blueprintId]),
            {
              from: participant,
            }
          );
        });

        it('burns the catalysts', async function () {
          await expectEvent.inTransaction(this.receipt.tx, this.catalysts, 'Transfer', {
            _from: participant,
            _to: ZeroAddress,
            _value: blueprintB.catalystCost,
          });
        });

        it('sends the REVV to the payout wallet', async function () {
          await expectEvent.inTransaction(this.receipt.tx, this.revv, 'Transfer', {
            _from: participant,
            _to: payoutWallet,
            _value: blueprintB.revvCost,
          });
        });

        it('moves the spent cars to the yard', async function () {
          expectEvent(this.receipt, 'TransferBatch', {
            _operator: this.proxy.address,
            _from: this.proxy.address,
            _to: yard,
            _ids: [blueprintBCar1, blueprintBCar2],
            _values: [1, 1],
          });
        });

        it('mints the new car to the owner', async function () {
          expectEvent(this.receipt, 'TransferSingle', {
            _operator: this.proxy.address,
            _from: ZeroAddress,
            _to: participant,
            _id: blueprintB.deliveredTokenMask.or(new BN('1')),
            _value: 1,
          });
        });
      });
    });
  });

  behaviors.shouldSupportInterfaces([interfaces165.ERC165]);
});
