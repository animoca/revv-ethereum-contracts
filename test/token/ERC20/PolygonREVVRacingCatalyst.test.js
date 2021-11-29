const {artifacts, accounts, web3} = require('hardhat');
const {behaviors} = require('@animoca/ethereum-contracts-assets');
const {shouldBehaveLikeERC20} = behaviors;

const implementation = {
  contractName: 'PolygonREVVRacingCatalystMock',
  name: 'REVV Racing Catalyst',
  symbol: 'CATA',
  decimals: '18',
  tokenURI: '',
  revertMessages: {
    // ERC20
    ApproveToZero: 'ERC20: zero address spender',
    TransferExceedsBalance: 'ERC20: insufficient balance',
    TransferToZero: 'ERC20: to zero address',
    TransferExceedsAllowance: 'ERC20: insufficient allowance',
    TransferFromZero: 'ERC20: insufficient balance',
    InconsistentArrays: 'ERC20: inconsistent arrays',
    SupplyOverflow: 'ERC20: supply overflow',

    // ERC20Allowance
    AllowanceUnderflow: 'ERC20: insufficient allowance',
    AllowanceOverflow: 'ERC20: allowance overflow',

    // ERC20BatchTransfers
    BatchTransferValuesOverflow: 'ERC20: values overflow',
    BatchTransferFromZero: 'ERC20: insufficient balance',

    // ERC20SafeTransfers
    TransferRefused: 'ERC20: transfer refused',

    // ERC2612
    PermitFromZero: 'ERC20: zero address owner',
    PermitExpired: 'ERC20: expired permit',
    PermitInvalid: 'ERC20: invalid permit',

    // ERC20Mintable
    MintToZero: 'ERC20: zero address',
    BatchMintValuesOverflow: 'ERC20: values overflow',

    // ERC20Burnable
    BurnFromZero: 'ERC20: insufficient balance',
    BurnExceedsBalance: 'ERC20: insufficient balance',
    BurnExceedsAllowance: 'ERC20: insufficient allowance',
    BatchBurnValuesOverflow: 'ERC20: insufficient balance',

    // ERC20Receiver
    DirectReceiverCall: 'ChildERC20: wrong sender',

    // Admin
    NotMinter: 'MinterRole: not a Minter',
    NotContractOwner: 'Ownable: not the owner',

    // Child
    NonDepositor: 'ChildERC20: only depositor',
  },
  features: {
    ERC165: true,
    EIP717: true, // unlimited approval
    AllowanceTracking: true,
    Recoverable: true,
  },
  interfaces: {
    ERC20: true,
    ERC20Detailed: true,
    ERC20Metadata: true,
    ERC20Allowance: true,
    ERC20BatchTransfer: true,
    ERC20Safe: true,
    ERC20Permit: true,
    ChildToken: true,
  },
  methods: {
    // ERC20Burnable
    'burn(uint256)': async (contract, value, overrides) => {
      return contract.burn(value, overrides);
    },
    'burnFrom(address,uint256)': async (contract, from, value, overrides) => {
      return contract.burnFrom(from, value, overrides);
    },
    'batchBurnFrom(address[],uint256[])': async (contract, owners, values, overrides) => {
      return contract.batchBurnFrom(owners, values, overrides);
    },

    // ERC20Mintable
    'mint(address,uint256)': async (contract, account, value, overrides) => {
      return contract.mint(account, value, overrides);
    },
    'batchMint(address[],uint256[])': async (contract, accounts, values, overrides) => {
      return contract.batchMint(accounts, values, overrides);
    },
  },
  deploy: async function (initialHolders, initialBalances, deployer) {
    const registry = await artifacts.require('ForwarderRegistry').new({from: deployer});
    const catalyst = await artifacts.require('PolygonREVVRacingCatalystMock').new(registry.address, deployer, {from: deployer});
    await catalyst.batchMint(initialHolders, initialBalances, {from: deployer});
    return catalyst;
  },
};

describe('PolygonREVVRacingCatalyst', function () {
  this.timeout(0);

  const [deployer, other] = accounts;

  context('_msgData()', function () {
    it('it is called for 100% coverage', async function () {
      const token = await implementation.deploy([], [], deployer);
      await token.msgData();
    });
  });

  shouldBehaveLikeERC20(implementation);
});
