const {artifacts, accounts, web3} = require('hardhat');
const {BN, expectRevert} = require('@openzeppelin/test-helpers');
const {constants} = require('@animoca/ethereum-contracts-core');
const {One, Two, ZeroAddress} = constants;
const {createFixtureLoader} = require('@animoca/ethereum-contracts-core/test/utils/fixture');
const {behaviors} = require('@animoca/ethereum-contracts-assets');
const {shouldBehaveLikeERC20} = behaviors;

const implementation = {
  contractName: 'PolygonREVV',
  name: 'REVV',
  symbol: 'REVV',
  decimals: new BN(18),
  tokenURI: '',
  revertMessages: {
    ApproveToZero: 'ERC20: zero address spender',
    TransferExceedsBalance: 'ERC20: insufficient balance',
    TransferToZero: 'ERC20: to zero address',
    TransferExceedsAllowance: 'ERC20: insufficient allowance',
    TransferFromZero: 'ERC20: insufficient balance',
    BatchTransferValuesOverflow: 'ERC20: values overflow',
    BatchTransferFromZero: 'ERC20: insufficient balance',
    AllowanceUnderflow: 'ERC20: insufficient allowance',
    AllowanceOverflow: 'ERC20: allowance overflow',
    InconsistentArrays: 'ERC20: inconsistent arrays',
    TransferRefused: 'ERC20: transfer refused',
    MintToZero: 'ERC20: zero address',
    BatchMintValuesOverflow: 'ERC20: values overflow',
    SupplyOverflow: 'ERC20: supply overflow',
    PermitFromZero: 'ERC20: zero address owner',
    PermitExpired: 'ERC20: expired permit',
    PermitInvalid: 'ERC20: invalid permit',
    NonMinter: 'Ownable: not the owner',
  },
  features: {
    ERC165: true,
    EIP717: true, // unlimited approval
    AllowanceTracking: true,
  },
  interfaces: {
    ERC20: true,
    ERC20Detailed: true,
    ERC20Metadata: true,
    ERC20Allowance: true,
    ERC20BatchTransfer: true,
    ERC20Safe: true,
    ERC20Permit: true,
  },
  methods: {},
  deploy: async function (initialHolders, initialBalances, deployer) {
    // const forwarder = await artifacts.require('NoStorageUniversalForwarder').new({from: deployer});
    // const registry = await artifacts.require('ForwarderRegistry').new({from: deployer});
    // return artifacts.require('PolygonREVV').new(initialHolders, initialBalances, forwarder.address, registry.address, {from: deployer});
    return artifacts.require('PolygonREVV').new(initialHolders, initialBalances, ZeroAddress, ZeroAddress, {from: deployer});
  },
};

describe('PolygonREVV', function () {
  this.timeout(0);

  const [deployer, other] = accounts;

  // the initial supply is minted to the contract itself and no minting function is provided, tests will fail
  // todo make a mock version which complies with testing logic

  // context('constructor', function () {
  //   it('it reverts with inconsistent arrays', async function () {
  //     await expectRevert(implementation.deploy([], [Two], deployer), implementation.revertMessages.InconsistentArrays);
  //     await expectRevert(implementation.deploy([other, other], [Two], deployer), implementation.revertMessages.InconsistentArrays);
  //   });
  // });

  // shouldBehaveLikeERC20(implementation);
});
