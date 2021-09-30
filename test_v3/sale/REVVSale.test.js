// disabled until registry dependencies are fixed for sale_base

// const {artifacts, web3} = require('hardhat');
// const {BN, stringToHex, utf8ToHex, padRight, toWei, toChecksumAddress} = web3.utils;
// const {ether, balance, expectEvent, expectRevert} = require('@openzeppelin/test-helpers');
// const {constants} = require('@animoca/ethereum-contracts-core');
// const {EthAddress, ZeroAddress, Two} = constants;

// function stringToBytes32(value) {
//   return padRight(utf8ToHex(value.slice(0, 32)), 64);
// }

// const sku = stringToBytes32('flash REVV');
// const daiPrice = new BN('6660000000000000');
// const ethPrice = new BN('16650000000000');

// const totalSupply = '7500000'; // 7.5M
// const maxPurchaseAmount = '700000'; // 700k

// let deployer, purchaser, payout;

// describe('REVVSale', function () {
//   before(async function () {
//     [deployer, purchaser, payout] = await web3.eth.getAccounts();
//   });
//   beforeEach(async function () {
//     const DAI = artifacts.require('ERC20Mock');
//     this.dai = await DAI.new([purchaser], [toWei('100000000')], {from: deployer});

//     const REVV = artifacts.require('REVV');
//     this.revv = await REVV.new([deployer], [toWei(totalSupply)], {from: deployer});

//     const Bytes = artifacts.require('Bytes');
//     const bytes = await Bytes.new({from: deployer});

//     const Inventory = artifacts.require('DeltaTimeInventory');
//     await Inventory.link(bytes);
//     this.inventory = await Inventory.new(this.revv.address, payout, {from: deployer});

//     const Sale = artifacts.require('REVVSale');
//     this.sale = await Sale.new(this.revv.address, this.inventory.address, payout, {from: deployer});

//     await this.revv.approve(this.sale.address, toWei(totalSupply), {from: deployer});
//     await this.sale.createSku(sku, totalSupply, maxPurchaseAmount, ZeroAddress, {from: deployer});

//     const prices = {}; // in wei
//     prices[this.dai.address] = daiPrice;
//     prices[EthAddress] = ethPrice;
//     await this.sale.updateSkuPricing(sku, Object.keys(prices), Object.values(prices), {from: deployer});

//     await this.sale.start({from: deployer});
//   });
//   describe('purchaseFor()', function () {
//     it('reverts if purchaser is not an NFT owner', async function () {
//       const quantity = Two;
//       const paymentToken = EthAddress;

//       await expectRevert(
//         this.sale.purchaseFor(purchaser, paymentToken, sku, quantity, '0x', {
//           from: purchaser,
//           value: ethPrice.mul(quantity),
//         }),
//         'REVVSale: must be a NFT owner'
//       );
//     });

//     it('should purchase successfully with ETH', async function () {
//       // Mint an NFT to the purchaser
//       await this.inventory.batchMint(
//         [purchaser],
//         ['0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'], // an NFT
//         ['0x'],
//         [1],
//         true,
//         {
//           from: deployer,
//         }
//       );

//       const quantity = 1;
//       const paymentToken = EthAddress;

//       const previous = await balance.current(purchaser);
//       const receipt = await this.sale.purchaseFor(purchaser, paymentToken, sku, quantity, '0x', {
//         from: purchaser,
//         value: ethPrice,
//         gasPrice: 0,
//       });
//       const delta = (await balance.current(purchaser)).sub(previous);
//       expect(delta).to.be.bignumber.equal(ethPrice.neg());

//       await expectEvent(receipt, 'Purchase', {
//         purchaser: purchaser,
//         recipient: purchaser,
//         token: toChecksumAddress(paymentToken),
//         sku,
//         quantity,
//         userData: null,
//         totalPrice: ethPrice,
//         pricingData: [],
//         paymentData: [],
//         deliveryData: [],
//       });

//       await expectEvent.inTransaction(receipt.tx, this.revv, 'Transfer', {
//         _from: this.sale.address,
//         _to: purchaser,
//         _value: toWei('1'),
//       });
//     });

//     it('should purchase successfully with DAI', async function () {
//       // Mint an NFT to the purchaser
//       await this.inventory.batchMint(
//         [purchaser],
//         ['0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF'], // an NFT
//         ['0x'],
//         [1],
//         true,
//         {
//           from: deployer,
//         }
//       );

//       const quantity = 1;
//       const paymentToken = this.dai.address;
//       await this.dai.approve(this.sale.address, daiPrice, {from: purchaser});

//       const receipt = await this.sale.purchaseFor(purchaser, paymentToken, sku, quantity, '0x', {
//         from: purchaser,
//       });

//       await expectEvent.inTransaction(receipt.tx, this.dai, 'Transfer', {
//         _from: purchaser,
//         _to: payout,
//         _value: daiPrice,
//       });

//       await expectEvent.inTransaction(receipt.tx, this.revv, 'Transfer', {
//         _from: this.sale.address,
//         _to: purchaser,
//         _value: toWei('1'),
//       });
//     });
//   });
// });
