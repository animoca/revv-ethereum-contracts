const {artifacts, accounts, ethers, web3} = require('hardhat');
const {BN, expectRevert, expectEvent} = require('@openzeppelin/test-helpers');
const {createFixtureLoader} = require('@animoca/ethereum-contracts-core/test/utils/fixture');
const [deployer, anyone] = accounts;
const eip712 = require('./eip712');
const ethSigUtil = require('eth-sig-util');

describe('SessionsManager Meta Transaction', function () {
  this.timeout(0);
  const fixtureLoader = createFixtureLoader(accounts, web3.eth.currentProvider);
  const fixture = async function () {
    const {Wallet} = ethers;
    this.participantWallet = Wallet.createRandom();
    this.participant = this.participantWallet.address;
    this.registry = await artifacts.require('ForwarderRegistry').new({from: deployer});
    this.forwarder = await artifacts.require('UniversalForwarder').new({from: deployer});
    this.revv = await artifacts
      .require('ERC20Mock')
      .new([this.participant], [new BN('100')], this.registry.address, this.forwarder.address, {from: deployer});
    this.sessionManager = await artifacts.require('SessionsManager').new(this.revv.address, deployer, {from: deployer});
    this.minimalForwarder = await artifacts.require('MinimalForwarder').new({from: deployer});
    this.chainId = await web3.eth.net.getId();
  };

  beforeEach(async function () {
    await fixtureLoader(fixture, this);
    await this.sessionManager.addFreeSessions(new BN(1), {from: deployer});
    await this.sessionManager.setSessionPrice(new BN(10), {from: deployer});
  });

  describe('Session Manager', function () {
    it('should be able to purchase sesssion through approveAndForward', async function () {
      // make the session id purchase here.
      const sessionId = 'the_session_id';
      const sessionIdData = web3.eth.abi.encodeParameters(['string'], [sessionId]);
      const contractCallData = this.revv.contract.methods.safeTransfer(this.sessionManager.address, new BN(0), sessionIdData).encodeABI();
      const registryNonce = await this.registry.getNonce(this.participant, this.minimalForwarder.address);
      const approveForwarderMessage = eip712.ApproveForwarder(
        this.chainId,
        this.registry.address,
        this.minimalForwarder.address,
        true,
        Number(registryNonce)
      );
      const approveForwarderSignature = await this.participantWallet._signTypedData(
        approveForwarderMessage.domain,
        approveForwarderMessage.types,
        approveForwarderMessage.message
      );
      const approveForwarderCallData = this.registry.contract.methods
        .approveAndForward(approveForwarderSignature, 0, this.revv.address, contractCallData)
        .encodeABI();
      // const approveForwarderCallData = this.registry.contract.methods.approveForwarder(true, approveForwarderSignature, 0).encodeABI();
      const forwardRequest = {
        from: this.participant,
        to: this.registry.address,
        value: '0',
        gas: '1000000',
        nonce: Number(await this.minimalForwarder.getNonce(this.participant)),
        data: approveForwarderCallData,
      };
      const forwardRequestMessage = eip712.ForwardRequest(this.chainId, this.minimalForwarder.address, forwardRequest);
      // implementation of MinimalForwarder eip712 is differ from Forwarder Registry.
      const forwardRequestSignature = await ethSigUtil.signTypedMessage(Buffer.from(this.participantWallet.privateKey.slice(2), 'hex'), {
        data: forwardRequestMessage,
      });
      const receipt = await this.minimalForwarder.execute(forwardRequest, forwardRequestSignature, {from: deployer});
      await expectEvent.inTransaction(receipt.tx, this.sessionManager, 'Admission', {
        account: this.participant,
        sessionId,
        amount: 0,
      });
      await expectEvent.inTransaction(receipt.tx, this.registry, 'ForwarderApproved', {
        signer: this.participant,
        forwarder: this.minimalForwarder.address,
        approved: true,
        nonce: 0,
      });
      (await this.registry.isForwarderFor(this.participant, this.minimalForwarder.address)).should.be.true;
      (await this.registry.getNonce(this.participant, this.minimalForwarder.address)).should.be.bignumber.equal('1');
      const contractCallData2 = this.revv.contract.methods.safeTransfer(this.sessionManager.address, new BN(10), sessionIdData).encodeABI();
      const forwardRequest2 = {
        from: this.participant,
        to: this.revv.address,
        value: '0',
        gas: '1000000',
        nonce: Number(await this.minimalForwarder.getNonce(this.participant)),
        data: contractCallData2,
      };
      const forwardRequestMessage2 = eip712.ForwardRequest(this.chainId, this.minimalForwarder.address, forwardRequest2);
      const forwardRequestSignature2 = await ethSigUtil.signTypedMessage(Buffer.from(this.participantWallet.privateKey.slice(2), 'hex'), {
        data: forwardRequestMessage2,
      });
      const receiptAfterApproval = await this.minimalForwarder.execute(forwardRequest2, forwardRequestSignature2, {from: deployer});
      await expectEvent.inTransaction(receiptAfterApproval.tx, this.sessionManager, 'Admission', {
        account: this.participant,
        sessionId,
        amount: 10,
      });
    });
  });
});
