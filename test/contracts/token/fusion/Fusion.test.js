const {ethers} = require('hardhat');
const {BigNumber, constants, utils} = ethers;
const {deployContract} = require('@animoca/ethereum-contract-helpers/src/test/deploy');
const {loadFixture} = require('@animoca/ethereum-contract-helpers/src/test/fixtures');
const {runBehaviorTests} = require('@animoca/ethereum-contract-helpers/src/test/run');
const {getDeployerAddress} = require('@animoca/ethereum-contract-helpers/src/test/accounts');
const {getForwarderRegistryAddress} = require('@animoca/ethereum-contracts/test/helpers/registries');

const chassisMask = BigNumber.from('0xfffffff80000000000000000ff00000000000000000000000000ffff00000000');

const facet1BlueprintsSingle = [
  {
    name: 'Common_Rare_1',
    inputCarTokenId: BigNumber.from('57910179610855898424928160541739447587297712243704648546123968643847459705108'),
    outputCarBaseId: BigNumber.from('57910179610855898424928160547579767348767212279596058158364205242864464035840'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_2',
    inputCarTokenId: BigNumber.from('57910179610855899830998949268355938686514543042221925753051591581490911133816'),
    outputCarBaseId: BigNumber.from('57910179610855899830998949274196258447984043078113335365291825084283171635200'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_3',
    inputCarTokenId: BigNumber.from('57910179610855900534034343631664184236122958441480564356515403331787613562277'),
    outputCarBaseId: BigNumber.from('57910179610855900534034343637504503997592458477371973968755635145730013790208'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_4',
    inputCarTokenId: BigNumber.from('57910179610855898525361788307926339808670343015027311203761656036746988625526'),
    outputCarBaseId: BigNumber.from('57910179610855898525361788313766659570139843050918720816001893198713946374144'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_5',
    inputCarTokenId: BigNumber.from('57910179610855905053547593110074334644328517894302707960134720762972089634293'),
    outputCarBaseId: BigNumber.from('57910179610855905053547593115914653512870510684680436650546688775612859940864'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_6',
    inputCarTokenId: BigNumber.from('57910179610855905957450243005756364636682194836206671878873907299067849889811'),
    outputCarBaseId: BigNumber.from('57910179610855905957450243011596683505224187626584400569285873059908806508544'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_7',
    inputCarTokenId: BigNumber.from('57910179610855907564388287264746640178644287177369274401076905585460312588221'),
    outputCarBaseId: BigNumber.from('57910179610855907564388287270586959047186279967747003091488867124176618520576'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_8',
    inputCarTokenId: BigNumber.from('57910179610855907865689170563307316842762179491337262373989967764158899331839'),
    outputCarBaseId: BigNumber.from('57910179610855907865689170569147635711304172281714991064401928739925251850240'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_9',
    inputCarTokenId: BigNumber.from('57910179610855907966122798329494209064134810262659925031627655157058428242819'),
    outputCarBaseId: BigNumber.from('57910179610855907966122798335334527932676803053037653722039616132824780767232'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_10',
    inputCarTokenId: BigNumber.from('57910179610855908166990053861867993506880071805305250346903029942857486067494'),
    outputCarBaseId: BigNumber.from('57910179610855908166990053867708312375422064595682979037314990637148861890560'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
];

const facet1BlueprintsDuo = [
  {
    name: 'Common_Rare_11',
    inputCarTokenId1: BigNumber.from('57910179610855907564388287264746640178644287177369274401076905585460312588221'),
    inputCarTokenId2: BigNumber.from('57910179610855907865689170563307316842762179491337262373989967764158899331839'),
    outputCarBaseId: BigNumber.from('57910179610855916804282041759781043413468310929431967594156082501135328346112'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'Common_Rare_12',
    inputCarTokenId1: BigNumber.from('57910179610855907966122798329494209064134810262659925031627655157058428242819'),
    inputCarTokenId2: BigNumber.from('57910179610855908166990053861867993506880071805305250346903029942857486067494'),
    outputCarBaseId: BigNumber.from('57910179610855916904715669525967935634840941700754630251793769894034857263104'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('300'),
    catalystCost: utils.parseEther('1'),
  },
];

const defaultCar1 = BigNumber.from('0xff00000000000000000000000000000000000000000000000000000000000001');
const defaultCar2 = BigNumber.from('0xff00000000000000000000000000000000000000000000000000000000000002');

const config = {
  diamond: {
    facets: [
      {name: 'ProxyAdminFacet', ctorArguments: ['forwarderRegistry'], init: {method: 'initProxyAdminStorage', arguments: ['initialAdmin']}},
      {name: 'DiamondCutFacet', ctorArguments: ['forwarderRegistry'], init: {method: 'initDiamondCutStorage'}},
      {name: 'InterfaceDetectionFacet'},
      {
        name: 'ContractOwnershipFacet',
        ctorArguments: ['forwarderRegistry'],
        init: {method: 'initContractOwnershipStorage', arguments: ['initialOwner']},
      },
      {name: 'AccessControlFacet', ctorArguments: ['forwarderRegistry']},
      {name: 'PayoutWalletFacet', ctorArguments: ['forwarderRegistry'], init: {method: 'initPayoutWalletStorage', arguments: ['payoutWallet']}},
      {name: 'TokenRecoveryFacet', ctorArguments: ['forwarderRegistry']},
      {
        name: 'FusionFacetMock',
        ctorArguments: ['forwarderRegistry'],
        init: {method: 'initFusionStorage', arguments: ['yard'], adminProtected: true, versionProtected: true},
        testMsgData: true,
      },
      {
        name: 'BlueprintFacet1Mock',
        ctorArguments: ['cars', 'revv', 'cata', 'forwarderRegistry'],
        testMsgData: true,
      },
    ],
  },
  defaultArguments: {
    forwarderRegistry: getForwarderRegistryAddress,
    initialAdmin: getDeployerAddress,
    initialOwner: getDeployerAddress,
    payoutWallet: getDeployerAddress,
    yard: getDeployerAddress,
    cars: constants.AddressZero,
    revv: constants.AddressZero,
    cata: constants.AddressZero,
  },
};

runBehaviorTests('Fusion', config, function (deployFn) {
  let deployer, participant, payoutWallet, yard, other;

  before(async function () {
    [deployer, participant, payoutWallet, yard, other] = await ethers.getSigners();
  });

  const fixture = async function () {
    const forwarderRegistryAddress = await getForwarderRegistryAddress();

    this.cars = await deployContract('ERC721BurnableMock', '', '', forwarderRegistryAddress);
    await this.cars.grantRole(await this.cars.MINTER_ROLE(), deployer.address);
    await this.cars.batchMint(participant.address, [defaultCar1, defaultCar2]);

    this.revv = await deployContract('ERC20MintBurnMock', '', '', 18, forwarderRegistryAddress);
    await this.revv.grantRole(await this.revv.MINTER_ROLE(), deployer.address);
    await this.revv.mint(participant.address, constants.MaxUint256);

    this.cata = await deployContract('REVVRacingCatalystMock', forwarderRegistryAddress);
    await this.cata.grantRole(await this.cata.MINTER_ROLE(), deployer.address);
    this.cata.mint(participant.address, constants.MaxUint256);

    this.contract = await deployFn({
      payoutWallet: payoutWallet.address,
      cars: this.cars.address,
      revv: this.revv.address,
      cata: this.cata.address,
      yard: yard.address,
    });

    await this.cars.connect(participant).setApprovalForAll(this.contract.address, true);
    await this.revv.connect(participant).approve(this.contract.address, constants.MaxUint256);
    await this.cata.connect(participant).approve(this.contract.address, constants.MaxUint256);

    await this.cars.grantRole(await this.cars.MINTER_ROLE(), this.contract.address);
  };

  beforeEach(async function () {
    await loadFixture(fixture, this);
  });

  describe('Fusion Facet', function () {
    it('sets the yard address', async function () {
      expect(await this.contract.yard()).to.equal(yard.address);
    });

    describe('setYard(address)', function () {
      it('reverts if not sent by the contract owner', async function () {
        await expect(this.contract.connect(other).setYard(constants.AddressZero)).to.be.revertedWith('Ownership: not the owner');
      });

      it('sets the yard', async function () {
        await this.contract.setYard(constants.AddressZero);
        expect(await this.contract.yard()).to.equal(constants.AddressZero);
      });
    });
  });

  describe('Blueprint Facet 1 (single car)', function () {
    it('reverts if the the chassis number of the base output car id is not zero', async function () {
      await this.cars.mint(participant.address, '57910179610855898424928160541739447587297712243704648546123968643847459705108');
      await expect(this.contract.connect(participant).fuseWrongbaseOutputCarId()).to.be.revertedWith('Fusion: invalid output base id');
    });

    for (const blueprint of facet1BlueprintsSingle) {
      const method = `fuse_${blueprint.name}(uint256)`;
      describe(method, function () {
        it('reverts if the car is of an incorrect type', async function () {
          await expect(this.contract.connect(participant)[method](defaultCar1)).to.be.revertedWith('Fusion: wrong car type');
        });

        context('when successful', function () {
          beforeEach(async function () {
            await this.cars.mint(participant.address, blueprint.inputCarTokenId);
            this.receipt = await this.contract.connect(participant)[method](blueprint.inputCarTokenId);
          });

          it('burns the catalysts', async function () {
            await expect(this.receipt).to.emit(this.cata, 'Transfer').withArgs(participant.address, constants.AddressZero, blueprint.catalystCost);
          });

          it('sends the REVV to the payout wallet', async function () {
            await expect(this.receipt).to.emit(this.revv, 'Transfer').withArgs(participant.address, payoutWallet.address, blueprint.revvCost);
          });

          it('moves the spent car to the yard', async function () {
            await expect(this.receipt).to.emit(this.cars, 'Transfer').withArgs(participant.address, yard.address, blueprint.inputCarTokenId);
          });

          it('mints the new car to the owner', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'Transfer')
              .withArgs(constants.AddressZero, participant.address, blueprint.outputCarBaseId.add(constants.One));
          });

          it('increases the chassis number', async function () {
            expect(await this.contract.chassisNumber(blueprint.outputCarBaseId.and(chassisMask))).to.equal(1);
          });
        });
      });
    }
  });

  describe('Blueprint Facet 1 (duo car)', function () {
    for (const blueprint of facet1BlueprintsDuo) {
      const method = `fuse_${blueprint.name}(uint256,uint256)`;
      describe(method, function () {
        it('reverts if the car is of an incorrect type', async function () {
          await expect(this.contract.connect(participant)[method](defaultCar1, defaultCar2)).to.be.revertedWith('Fusion: wrong car type');
        });

        context('when successful', function () {
          beforeEach(async function () {
            await this.cars.batchMint(participant.address, [blueprint.inputCarTokenId1, blueprint.inputCarTokenId2]);
            this.receipt = await this.contract.connect(participant)[method](blueprint.inputCarTokenId1, blueprint.inputCarTokenId2);
          });

          it('burns the catalysts', async function () {
            await expect(this.receipt).to.emit(this.cata, 'Transfer').withArgs(participant.address, constants.AddressZero, blueprint.catalystCost);
          });

          it('sends the REVV to the payout wallet', async function () {
            await expect(this.receipt).to.emit(this.revv, 'Transfer').withArgs(participant.address, payoutWallet.address, blueprint.revvCost);
          });

          it('moves the spent cars to the yard', async function () {
            await expect(this.receipt).to.emit(this.cars, 'Transfer').withArgs(participant.address, yard.address, blueprint.inputCarTokenId1);
            await expect(this.receipt).to.emit(this.cars, 'Transfer').withArgs(participant.address, yard.address, blueprint.inputCarTokenId2);
          });

          it('mints the new car to the owner', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'Transfer')
              .withArgs(constants.AddressZero, participant.address, blueprint.outputCarBaseId.add(constants.One));
          });

          it('increases the chassis number', async function () {
            expect(await this.contract.chassisNumber(blueprint.outputCarBaseId.and(chassisMask))).to.equal(1);
          });
        });
      });
    }
  });
});
