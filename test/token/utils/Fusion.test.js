const {artifacts, accounts, web3} = require('hardhat');
const {BN, expectRevert, expectEvent} = require('@openzeppelin/test-helpers');
const interfaces165 = require('@animoca/ethereum-contracts-core/src/interfaces/ERC165');
const {constants, behaviors} = require('@animoca/ethereum-contracts-core');
const {ZeroAddress, EmptyByte, MaxUInt256, ZeroBytes32} = constants;
const {createFixtureLoader} = require('@animoca/ethereum-contracts-core/test/utils/fixture');
const fusionFacetABI = require('../../../artifacts/contracts/token/fusion/facets/FusionFacet.sol/FusionFacet.json').abi;

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

    this.fusionFacet = await artifacts.require('FusionFacet').new();

    const diamantaire = await artifacts.require('Diamantaire').new();
    const diamond = await diamantaire.createDiamond(
      deployer,
      [
        [
          this.fusionFacet.address,
          0, // Add
          fusionFacetABI
            .filter((el) =>
              [
                'initFusionStorage',
                'setBlueprint',
                'setPayoutWallet',
                'blueprint',
                'payoutWallet',
                'cars',
                'catalysts',
                'revv',
                'yard',
                'counters',
                'onERC1155Received',
                'onERC1155BatchReceived',
              ].includes(el.name)
            )
            .map((el) => web3.eth.abi.encodeFunctionSignature(el)),
        ],
      ],
      web3.eth.abi.encodeFunctionCall(
        fusionFacetABI.find((el) => el.name === 'initFusionStorage'),
        [this.cars.address, this.catalysts.address, this.revv.address, this.counters.address, payoutWallet, yard]
      ),
      ZeroBytes32
    );

    this.fusion = await artifacts.require('FusionFacet').at(diamond.logs[0].args.diamond);

    await this.counters.addMinter(this.fusion.address, {from: deployer});
    await this.cars.addMinter(this.fusion.address, {from: deployer});

    this.blueprintA = await artifacts
      .require('BlueprintA')
      .new(blueprintA.spentTokenMask, blueprintA.deliveredTokenMask, blueprintA.catalystCost, blueprintA.revvCost, {from: deployer});
    await this.fusion.setBlueprint(blueprintA.blueprintId, this.blueprintA.address, {from: deployer});

    this.blueprintB = await artifacts
      .require('BlueprintB')
      .new(blueprintB.spentTokenMask1, blueprintB.spentTokenMask2, blueprintB.deliveredTokenMask, blueprintB.catalystCost, blueprintB.revvCost, {
        from: deployer,
      });
    await this.fusion.setBlueprint(blueprintB.blueprintId, this.blueprintB.address, {from: deployer});

    // for ERC165 `shouldSupportInterfaces` tests
    this.contract = await artifacts.require('DiamondLoupeFacet').at(diamond.logs[0].args.diamond);
  };

  beforeEach(async function () {
    await fixtureLoader(fixture, this);
  });

  describe('FusionProxy', function () {
    describe('initFusionStorage()', function () {
      it('reverts if called again after initialisation', async function () {
        await expectRevert(
          this.fusion.initFusionStorage(this.cars.address, this.catalysts.address, this.revv.address, this.counters.address, payoutWallet, yard),
          'Fusion: storage initialised'
        );
      });

      it('sets the cars address', async function () {
        (await this.fusion.cars()).should.be.equal(this.cars.address);
      });

      it('sets the catalysts address', async function () {
        (await this.fusion.catalysts()).should.be.equal(this.catalysts.address);
      });

      it('sets the REVV address', async function () {
        (await this.fusion.revv()).should.be.equal(this.revv.address);
      });

      it('sets the counters address', async function () {
        (await this.fusion.counters()).should.be.equal(this.counters.address);
      });

      it('sets the payout wallet', async function () {
        (await this.fusion.payoutWallet()).should.be.equal(payoutWallet);
      });

      it('sets the yard address', async function () {
        (await this.fusion.yard()).should.be.equal(yard);
      });
    });

    describe('setBlueprint(uint256,address)', function () {
      it('reverts if not sent by the contract owner', async function () {
        await expectRevert(this.fusion.setBlueprint(0, ZeroAddress, {from: participant}), 'LibDiamond: Must be contract owner');
      });

      it('sets the blueprint', async function () {
        await this.fusion.setBlueprint(0, other, {from: deployer});
        (await this.fusion.blueprint(0)).should.be.equal(other);
      });

      it('sets the blueprint (with a zero address arg)', async function () {
        await this.fusion.setBlueprint(0, ZeroAddress, {from: deployer});
        (await this.fusion.blueprint(0)).should.be.equal(ZeroAddress);
      });
    });

    describe('setPayoutWallet(address)', function () {
      it('reverts if not sent by the contract owner', async function () {
        await expectRevert(this.fusion.setPayoutWallet(participant, {from: participant}), 'LibDiamond: Must be contract owner');
      });

      it('sets the payout wallet', async function () {
        await this.fusion.setPayoutWallet(participant, {from: deployer});
        (await this.fusion.payoutWallet()).should.be.equal(participant);
      });
    });

    describe('onERC1155Received()', function () {
      it('reverts if the blueprint is not set', async function () {
        await expectRevert.unspecified(
          this.fusion.onERC1155Received(ZeroAddress, ZeroAddress, blueprintACar1, 1, EmptyByte, {
            from: participant,
          })
        );
      });

      it('reverts if the blueprint does not exist', async function () {
        await expectRevert(
          this.fusion.onERC1155Received(ZeroAddress, ZeroAddress, blueprintACar1, 1, web3.eth.abi.encodeParameters(['uint256'], [10]), {
            from: participant,
          }),
          'Fusion: non-existent blueprint'
        );
      });

      it('reverts if not called by the cars contract', async function () {
        await expectRevert(
          this.fusion.onERC1155Received(
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
            this.fusion.address,
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
        await this.revv.approve(this.fusion.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.fusion.address, MaxUInt256, {from: participant});
        await expectRevert(
          this.cars.methods['safeTransferFrom(address,address,uint256,uint256,bytes)'](
            participant,
            this.fusion.address,
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
          await this.revv.approve(this.fusion.address, MaxUInt256, {from: participant});
          await this.catalysts.approve(this.fusion.address, MaxUInt256, {from: participant});
          this.receipt = await this.cars.methods['safeTransferFrom(address,address,uint256,uint256,bytes)'](
            participant,
            this.fusion.address,
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
            _operator: this.fusion.address,
            _from: this.fusion.address,
            _to: yard,
            _id: blueprintACar1,
            _value: 1,
          });
        });

        it('mints the new car to the owner', async function () {
          expectEvent(this.receipt, 'TransferSingle', {
            _operator: this.fusion.address,
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
          this.fusion.onERC1155BatchReceived(ZeroAddress, ZeroAddress, [blueprintBCar1, blueprintBCar2], [1, 1], EmptyByte, {
            from: participant,
          })
        );
      });

      it('reverts if the blueprint does not exist', async function () {
        await expectRevert(
          this.fusion.onERC1155BatchReceived(
            ZeroAddress,
            ZeroAddress,
            [blueprintBCar1, blueprintBCar2],
            [1, 1],
            web3.eth.abi.encodeParameters(['uint256'], [10]),
            {
              from: participant,
            }
          ),
          'Fusion: non-existent blueprint'
        );
      });

      it('reverts if not sent by the cars contract', async function () {
        await expectRevert(
          this.fusion.onERC1155BatchReceived(
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
            this.fusion.address,
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
        await this.revv.approve(this.fusion.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.fusion.address, MaxUInt256, {from: participant});

        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.fusion.address,
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
        await this.revv.approve(this.fusion.address, MaxUInt256, {from: participant});
        await this.catalysts.approve(this.fusion.address, MaxUInt256, {from: participant});

        await expectRevert(
          this.cars.safeBatchTransferFrom(
            participant,
            this.fusion.address,
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
            this.fusion.address,
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
          await this.revv.approve(this.fusion.address, MaxUInt256, {from: participant});
          await this.catalysts.approve(this.fusion.address, MaxUInt256, {from: participant});
          this.receipt = await this.cars.safeBatchTransferFrom(
            participant,
            this.fusion.address,
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
            _operator: this.fusion.address,
            _from: this.fusion.address,
            _to: yard,
            _ids: [blueprintBCar1, blueprintBCar2],
            _values: [1, 1],
          });
        });

        it('mints the new car to the owner', async function () {
          expectEvent(this.receipt, 'TransferSingle', {
            _operator: this.fusion.address,
            _from: ZeroAddress,
            _to: participant,
            _id: blueprintB.deliveredTokenMask.or(new BN('1')),
            _value: 1,
          });
        });
      });
    });
  });

  behaviors.shouldSupportInterfaces([interfaces165.ERC165, interfaces165.ERC173], 29000);
});
