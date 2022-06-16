const {ethers} = require('hardhat');
const {BigNumber, utils} = ethers;
const {ZeroAddress, MaxUInt256, One} = require('@animoca/ethereum-contracts/src/constants');
const {getDeployerAddress, getForwarderRegistryAddress, runBehaviorTests} = require('@animoca/ethereum-contracts/test/helpers/run');
const {loadFixture} = require('@animoca/ethereum-contracts/test/helpers/fixtures');

const chassisMask = BigNumber.from('0xfffffff80000000000000000ff00000000000000000000000000ffff00000000');

const facet1BlueprintsSingle = [
  {
    name: 'NAME1',
    inputCarMatchValue: BigNumber.from('57910179610855898324494532775552547395017963456962744041009983425274905100288'),
    outputCarBaseId: BigNumber.from('57910179610855898324494532781392852826649382977650253965008245201603429138432'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME2',
    inputCarMatchValue: BigNumber.from('57910179610855898424928160541739439616390594228285406698647671381124387438592'),
    outputCarBaseId: BigNumber.from('57910179610855898424928160547579745048022013748972916622645932594502958055424'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME3',
    inputCarMatchValue: BigNumber.from('57910179610855899830998949268355930715607425026802683905575294318767838855168'),
    outputCarBaseId: BigNumber.from('57910179610855899830998949274196236147238844547490193829573552435921665654784'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME4',
    inputCarMatchValue: BigNumber.from('57910179610855900534034343631664176265215840426061322509039106069064541274112'),
    outputCarBaseId: BigNumber.from('57910179610855900534034343637504481696847259946748832433037362497368507809792'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME5',
    inputCarMatchValue: BigNumber.from('57910179610855898525361788307926331837763224999608069356285358774023916355584'),
    outputCarBaseId: BigNumber.from('57910179610855898525361788313766637269394644520295579280283620550352440393728'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME6',
    inputCarMatchValue: BigNumber.from('57910179610855905053547593110074326226984225135581142102735021016624104734720'),
    outputCarBaseId: BigNumber.from('57910179610855905053547593115914631212125312154057295114828416127251353960448'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME7',
    inputCarMatchValue: BigNumber.from('57910179610855905957450243005756356219337902077485106021474207552719864987648'),
    outputCarBaseId: BigNumber.from('57910179610855905957450243011596661204478989095961259033567600411547300528128'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
];

const facet1BlueprintsDuo = [
  {
    name: 'NAME8',
    inputCarMatchValue: BigNumber.from('57910179610855907564388287264746631761299994418647708543677205839112327659520'),
    outputCarBaseId: BigNumber.from('57910179610855907564388287270586936746441081437123861555770594475815112540160'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME9',
    inputCarMatchValue: BigNumber.from('57910179610855907865689170563307308425417886732615696516590268017810914410496'),
    outputCarBaseId: BigNumber.from('57910179610855907865689170569147613410558973751091849528683656091563745869824'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME10',
    inputCarMatchValue: BigNumber.from('57910179610855907966122798329494200646790517503938359174227955410710443327488'),
    outputCarBaseId: BigNumber.from('57910179610855907966122798335334505631931604522414512186321343484463274786816'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
  {
    name: 'NAME11',
    inputCarMatchValue: BigNumber.from('57910179610855908166990053861867985089535779046583684489503330196509501161472'),
    outputCarBaseId: BigNumber.from('57910179610855908166990053867708290074676866065059837501596717988787355910144'),
    inputCarRarity: 'common',
    outputCarRarity: 'rare',
    revvCost: utils.parseEther('150'),
    catalystCost: utils.parseEther('1'),
  },
];

const defaultCar1 = BigNumber.from('0xff00000000000000000000000000000000000000000000000000000000000001');
const defaultCar2 = BigNumber.from('0xff00000000000000000000000000000000000000000000000000000000000002');

const config = {
  diamond: {
    facets: [
      {name: 'ProxyAdminFacetMock', ctorArguments: ['forwarderRegistry'], init: {method: 'initProxyAdminStorage', arguments: ['initialAdmin']}},
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
    cars: ZeroAddress,
    revv: ZeroAddress,
    cata: ZeroAddress,
  },
};

runBehaviorTests('Fusion', config, function (deployFn) {
  let deployer, participant, payoutWallet, yard, other;

  before(async function () {
    [deployer, participant, payoutWallet, yard, other] = await ethers.getSigners();
  });

  const fixture = async function () {
    const forwarderRegistryAddress = await getForwarderRegistryAddress();

    const REVVRacingInventory = await ethers.getContractFactory('REVVRacingInventory');
    this.cars = await REVVRacingInventory.deploy(forwarderRegistryAddress, ZeroAddress);
    await this.cars.deployed();
    await this.cars.batchMint(participant.address, [defaultCar1, defaultCar2]);

    const REVV = await ethers.getContractFactory('ERC20Mock');
    this.revv = await REVV.deploy([participant.address], [MaxUInt256], '', '', '18', '', forwarderRegistryAddress);
    await this.revv.deployed();

    const REVVRacingCatalyst = await ethers.getContractFactory('REVVRacingCatalystMock');
    this.cata = await REVVRacingCatalyst.deploy([participant.address], [MaxUInt256], forwarderRegistryAddress);
    await this.cata.deployed();

    this.contract = await deployFn({
      payoutWallet: payoutWallet.address,
      cars: this.cars.address,
      revv: this.revv.address,
      cata: this.cata.address,
      yard: yard.address,
    });

    await this.cars.connect(participant).setApprovalForAll(this.contract.address, true);
    await this.revv.connect(participant).approve(this.contract.address, MaxUInt256);
    await this.cata.connect(participant).approve(this.contract.address, MaxUInt256);

    await this.cars.addMinter(this.contract.address);
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
        await expect(this.contract.connect(other).setYard(ZeroAddress)).to.be.revertedWith('Ownership: not the owner');
      });

      it('sets the yard', async function () {
        await this.contract.setYard(ZeroAddress);
        expect(await this.contract.yard()).to.equal(ZeroAddress);
      });
    });
  });

  describe('Blueprint Facet 1 (single car)', function () {
    for (const blueprint of facet1BlueprintsSingle) {
      const method = `fuse_${blueprint.name}(uint256)`;
      describe(method, function () {
        it('reverts if the car is of an incorrect type', async function () {
          await expect(this.contract.connect(participant)[method](defaultCar1)).to.be.revertedWith('Fusion: wrong car type');
        });

        context('when successful', function () {
          beforeEach(async function () {
            await this.cars.mint(participant.address, blueprint.inputCarMatchValue);
            this.receipt = await this.contract.connect(participant)[method](blueprint.inputCarMatchValue);
          });

          it('burns the catalysts', async function () {
            await expect(this.receipt).to.emit(this.cata, 'Transfer').withArgs(participant.address, ZeroAddress, blueprint.catalystCost);
          });

          it('sends the REVV to the payout wallet', async function () {
            await expect(this.receipt).to.emit(this.revv, 'Transfer').withArgs(participant.address, payoutWallet.address, blueprint.revvCost);
          });

          it('moves the spent car to the yard', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'TransferSingle')
              .withArgs(this.contract.address, participant.address, yard.address, blueprint.inputCarMatchValue, 1);
          });

          it('mints the new car to the owner', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'TransferSingle')
              .withArgs(this.contract.address, ZeroAddress, participant.address, blueprint.outputCarBaseId.add(One), 1);
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
          const car1 = blueprint.inputCarMatchValue;
          const car2 = blueprint.inputCarMatchValue.add(One);

          beforeEach(async function () {
            await this.cars.batchMint(participant.address, [car1, car2]);
            this.receipt = await this.contract.connect(participant)[method](car1, car2);
          });

          it('burns the catalysts', async function () {
            await expect(this.receipt).to.emit(this.cata, 'Transfer').withArgs(participant.address, ZeroAddress, blueprint.catalystCost);
          });

          it('sends the REVV to the payout wallet', async function () {
            await expect(this.receipt).to.emit(this.revv, 'Transfer').withArgs(participant.address, payoutWallet.address, blueprint.revvCost);
          });

          it('moves the spent cars to the yard', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'TransferBatch')
              .withArgs(this.contract.address, participant.address, yard.address, [car1, car2], [1, 1]);
          });

          it('mints the new car to the owner', async function () {
            await expect(this.receipt)
              .to.emit(this.cars, 'TransferSingle')
              .withArgs(this.contract.address, ZeroAddress, participant.address, blueprint.outputCarBaseId.add(One), 1);
          });

          it('increases the chassis number', async function () {
            expect(await this.contract.chassisNumber(blueprint.outputCarBaseId.and(chassisMask))).to.equal(1);
          });
        });
      });
    }
  });
});
