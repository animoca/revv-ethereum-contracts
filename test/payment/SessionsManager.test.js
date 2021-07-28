const {artifacts, accounts, web3} = require('hardhat');
const {BN, expectRevert, expectEvent} = require('@openzeppelin/test-helpers');
const {constants} = require('@animoca/ethereum-contracts-core');
const {Zero, One, MaxUInt256, Two, ZeroAddress} = constants;
const {createFixtureLoader} = require('@animoca/ethereum-contracts-core/test/utils/fixture');

const [deployer, participant, other] = accounts;

const sessionId = 'my_session_id';
const encodedSessionId = web3.eth.abi.encodeParameters(['string'], ['my_session_id']);

describe('SessionsManager', function () {
  this.timeout(0);

  const fixtureLoader = createFixtureLoader(accounts, web3.eth.currentProvider);
  const fixture = async function () {
    const registry = await artifacts.require('ForwarderRegistry').new({from: deployer});
    const forwarder = await artifacts.require('UniversalForwarder').new({from: deployer});
    this.revv = await artifacts.require('ERC20Mock').new([participant], [new BN('10')], registry.address, forwarder.address, {from: deployer});
    this.contract = await artifacts
      .require('SessionsManager')
      .new(registry.address, forwarder.address, this.revv.address, deployer, {from: deployer});
  };

  beforeEach(async function () {
    await fixtureLoader(fixture, this);
  });

  describe('setSessionPrice', function () {
    it('it reverts if the sender is not the contract owner', async function () {
      await expectRevert(this.contract.setSessionPrice(One, {from: other}), 'Ownable: not the owner');
    });

    it('it sets the new price', async function () {
      const price = new BN('100');
      await this.contract.setSessionPrice(price, {from: deployer});
      (await this.contract.sessionPrice()).should.be.bignumber.equal(price);
    });
  });

  describe('addFreeSessions', function () {
    it('it reverts if the sender is not the contract owner', async function () {
      await expectRevert(this.contract.addFreeSessions(One, {from: other}), 'Ownable: not the owner');
    });

    it('it reverts if the sessions overflow', async function () {
      await this.contract.addFreeSessions(One, {from: deployer});
      await expectRevert(this.contract.addFreeSessions(MaxUInt256, {from: deployer}), 'Sessions: sessions overflow');
    });

    it('it sets the additional sessions', async function () {
      (await this.contract.freeSessions()).should.be.bignumber.equal(Zero);
      await this.contract.addFreeSessions(One, {from: deployer});
      (await this.contract.freeSessions()).should.be.bignumber.equal(One);
      await this.contract.addFreeSessions(new BN('10'), {from: deployer});
      (await this.contract.freeSessions()).should.be.bignumber.equal(new BN('11'));
    });
  });

  describe('onERC20Received', function () {
    it('it reverts if the sender is not the PolygonREVV contract', async function () {
      await expectRevert(this.contract.onERC20Received(ZeroAddress, ZeroAddress, One, '0x0', {from: participant}), 'Sessions: wrong token');
    });

    it('it reverts if the session price has not been set yet', async function () {
      await expectRevert(this.revv.safeTransfer(this.contract.address, One, '0x0', {from: participant}), 'Sessions: price not set');
    });

    it('it reverts if the PolygonREVV amount is incorrect (free session)', async function () {
      await this.contract.setSessionPrice(One, {from: deployer});
      await this.contract.addFreeSessions(One, {from: deployer});
      await expectRevert(this.revv.safeTransfer(this.contract.address, One, '0x0', {from: participant}), 'Sessions: session is free');
    });

    it('it reverts if the PolygonREVV amount is incorrect (paid session)', async function () {
      await this.contract.setSessionPrice(One, {from: deployer});
      await expectRevert(this.revv.safeTransfer(this.contract.address, Zero, '0x0', {from: participant}), 'Sessions: wrong price');
      await expectRevert(this.revv.safeTransfer(this.contract.address, Two, '0x0', {from: participant}), 'Sessions: wrong price');
    });

    const price = Two;

    describe('when successful (free session)', function () {
      beforeEach(async function () {
        await this.contract.addFreeSessions(One, {from: deployer});
        await this.contract.setSessionPrice(price, {from: deployer});
        this.receipt = await this.revv.safeTransfer(this.contract.address, Zero, encodedSessionId, {
          from: participant,
        });
      });

      it('increments the user free sessions counter', async function () {
        (await this.contract.freeSessionsUsed(participant)).should.be.bignumber.equal(One);
      });

      it('it emits an Admission event', async function () {
        await expectEvent.inTransaction(this.receipt.tx, this.contract, 'Admission', {
          account: participant,
          sessionId,
          amount: Zero,
        });
      });
    });

    describe('when successful (paid session)', function () {
      beforeEach(async function () {
        await this.contract.setSessionPrice(price, {from: deployer});
        this.receipt = await this.revv.safeTransfer(this.contract.address, Two, encodedSessionId, {
          from: participant,
        });
      });

      it('does not increment the user free sessions counter', async function () {
        (await this.contract.freeSessionsUsed(participant)).should.be.bignumber.equal(Zero);
      });

      it('it emits an ERC20 Transfer event to the payout wallet', async function () {
        expectEvent(this.receipt, 'Transfer', {
          _from: this.contract.address,
          _to: deployer,
          _value: price,
        });
      });

      it('it emits an Admission event', async function () {
        await expectEvent.inTransaction(this.receipt.tx, this.contract, 'Admission', {
          account: participant,
          sessionId,
          amount: price,
        });
      });
    });
  });
});
