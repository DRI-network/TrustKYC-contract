const KYCCertifier = artifacts.require("./KYCCertifier.sol");
const KYCRegistry = artifacts.require("./KYCRegistry.sol");
const KYCToken = artifacts.require("./KYCToken.sol")

var kycCertifier;
var kycToken;
var decimals;
var kycRegistry;

contract('MultiCertifierTest', function (accounts) {

  const addresses = [
    accounts[0],
    accounts[1],
    accounts[2],
  ]
  const newAddress = accounts[3]
  const newAddress2 = accounts[4]

  it("should be deployed and init token for KYCCertifier", async function () {

    kycToken = await KYCToken.new()
    kycRegistry = await KYCRegistry.new();
    kycCertifier = await KYCCertifier.new();

    decimals = await kycToken.decimals()

    const dist1 = await kycToken.transfer(addresses[1], web3.toWei(250000, 'ether'))
    const dist2 = await kycToken.transfer(addresses[2], web3.toWei(250000, 'ether'))
    const dist3 = await kycToken.transfer(newAddress, web3.toWei(250000, 'ether'))


    //const balanceOfAccount = await kycToken.balanceOf(addresses[0])
    const balanceOfAccount1 = await kycToken.balanceOf(addresses[1])
    const balanceOfAccount2 = await kycToken.balanceOf(addresses[2])
    const balanceOfNewAddress = await kycToken.balanceOf(newAddress)

    //console.log(balanceOfAccount)

    // assert.strictEqual(balanceOfAccount.toNumber(), 50000 * 10 ** decimals, 'Transfer is not executed')
    assert.strictEqual(balanceOfAccount1.toNumber(), 250000 * 10 ** decimals, 'dist1 is not executed')
    assert.strictEqual(balanceOfAccount2.toNumber(), 250000 * 10 ** decimals, 'dist2 is not executed')
    assert.strictEqual(balanceOfNewAddress.toNumber(), 250000 * 10 ** decimals, 'dist3 is not executed')

    const init = await kycCertifier.init(kycToken.address, addresses);

    const isCertifier1 = await kycCertifier.isCertifier(addresses[0])
    const isCertifier2 = await kycCertifier.isCertifier(addresses[1])
    const isCertifier3 = await kycCertifier.isCertifier(addresses[2])

    assert.strictEqual(isCertifier1, true, 'Transfer is not executed')
    assert.strictEqual(isCertifier2, true, 'Transfer is not executed')
    assert.strictEqual(isCertifier3, true, 'Transfer is not executed')
  })

  it("should be claimed and set primary Certifier", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 70

    const claimCertifier = await kycCertifier.claimCertifier(addresses[0], now, true).catch((err) => {
      console.log(err)
    })

    const invoke = await kycCertifier.revokeCertifier({
      from: addresses[0]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'revokeCertifier is not executed')
    })
    
    const vote = await kycCertifier.vote().catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'vote is not executed')
    })

    const approveTokenToContract = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals)
    const approveTokenToContractWithSecondCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[1]
    })
    
    const voteWithNotSetPrimaryCertifier = await kycCertifier.vote()

    const voteWithSetPrimaryCertifier = await kycCertifier.vote({
      from: addresses[1]
    })

    const errorVote = await kycCertifier.vote({
      from: addresses[1]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'vote is not executed')
    })
    
  });

  it("should be claimed and put new Certifier account[3] 2/3", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 40

    const claimCertifier = await kycCertifier.claimCertifier(addresses[0], now, false).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'claimCertifier is not executed')
    })
    const now2 = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 40

    const claimCertifierWithNewAddress = await kycCertifier.claimCertifier(newAddress, now2, false).catch((err) => {
      console.log(err)
    })

    const invoke = await kycCertifier.revokeCertifier({
      from: addresses[0]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'revokeCertifier is not executed')
    })

    const vote = await kycCertifier.vote().catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'vote is not executed')
    })

    const approveTokenToContract = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals)
    const approveTokenToContractWithSecondCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[1]
    })

    const voteWithNotPutNewCertifier = await kycCertifier.vote()

    const voteWithPutNewCertifier = await kycCertifier.vote({
      from: addresses[1]
    })
    const certifiers = await kycCertifier.getCertifiers()

    assert.strictEqual(certifiers.length, 4, 'new certifier is not added')

  })

  it("should be claimed and put new Certifier account[4] 3/4", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 40

    const claimCertifier = await kycCertifier.claimCertifier(newAddress2, now, false)

    const invoke = await kycCertifier.revokeCertifier({
      from: addresses[0]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'revokeCertifier is not executed')
    })

    const vote = await kycCertifier.vote().catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'vote is not executed')
    })

    const approveTokenToContract = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals)
    const approveTokenToContractWithSecondCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[1]
    })

    const approveTokenToContractWithThirdCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[2]
    })

    const voteFromAddress0 = await kycCertifier.vote()


    const voteFromAddress1 = await kycCertifier.vote({
      from: addresses[1]
    })

    const voteFromAddress2 = await kycCertifier.vote({
      from: addresses[2]
    })
    const certifiers = await kycCertifier.getCertifiers()

    assert.strictEqual(certifiers.length, 5, 'new certifier is not added')

  })

  it("should be claimed and primary Certifier 4/5", async function () {
    const now = web3.eth.getBlock(web3.eth.blockNumber).timestamp + 40
    //console.log(newAddress2)
    const claimCertifier = await kycCertifier.claimCertifier(newAddress2, now, true)

    const invoke = await kycCertifier.revokeCertifier({
      from: addresses[0]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'revokeCertifier is not executed')
    })

    const vote = await kycCertifier.vote().catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: invalid opcode", 'vote is not executed')
    })

    const approveTokenToContract = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals)
    const approveTokenToContractWithSecondCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[1]
    })

    const approveTokenToContractWithTFourthCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[2]
    })

    const approveTokenToContractWithThirdCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: newAddress
    })

    const voteFromAddress0 = await kycCertifier.vote()


    const voteFromAddress1 = await kycCertifier.vote({
      from: addresses[1]
    })

    const voteFromAddress2 = await kycCertifier.vote({
      from: addresses[2]
    })

    const voteFromAddress3 = await kycCertifier.vote({
      from: newAddress
    })

    const primaryCertifier = await kycCertifier.getPrimaryCertifier()

    assert.strictEqual(primaryCertifier, newAddress2, 'newAddress2 is not set')
  })
})