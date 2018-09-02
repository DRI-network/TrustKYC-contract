const KYCCertifier = artifacts.require("./KYCCertifier.sol");
const KYCRegistry = artifacts.require("./KYCRegistry.sol");
const KYCToken = artifacts.require("./KYCToken.sol")
const KYCProject = artifacts.require("./kycProject.sol")


contract('KYCRegistryTest', function (accounts) {
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
    kycProject = await KYCProject.new();

    decimals = await kycToken.decimals()

    const dist1 = await kycToken.transfer(addresses[1], web3.toWei(250000, 'ether'))
    const dist2 = await kycToken.transfer(addresses[2], web3.toWei(250000, 'ether'))
    const dist4 = await kycToken.transfer(newAddress, web3.toWei(250000, 'ether'))


    //const balanceOfAccount = await kycToken.balanceOf(addresses[0])
    const balanceOfAccount1 = await kycToken.balanceOf(addresses[1])
    const balanceOfAccount2 = await kycToken.balanceOf(addresses[2])
    const balanceOfNewAddress = await kycToken.balanceOf(newAddress)

    //console.log(balanceOfAccount)

    // assert.strictEqual(balanceOfAccount.toNumber(), 50000 * 10 ** decimals, 'Transfer is not executed')
    assert.strictEqual(balanceOfAccount1.toNumber(), 250000 * 10 ** decimals, 'dist1 is not executed')
    assert.strictEqual(balanceOfAccount2.toNumber(), 250000 * 10 ** decimals, 'dist2 is not executed')
    assert.strictEqual(balanceOfNewAddress.toNumber(), 250000 * 10 ** decimals, 'dist4 is not executed')

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
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'revokeCertifier is not executed')
    })

    const vote = await kycCertifier.vote().catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'vote is not executed')
    })

    const approveTokenToContract = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals)
    const approveTokenToContractWithSecondCertifier = await kycToken.approve(kycCertifier.address, 50000 * 10 ** decimals, {
      from: addresses[1]
    })

    const voteWithNotSetPrimaryCertifier = await kycCertifier.vote()

    const voteWithSetPrimaryCertifier = await kycCertifier.vote({
      from: addresses[1]
    })


    const primary = await kycCertifier.getPrimaryCertifier();
    assert.strictEqual(primary, addresses[0], 'Primary is not set')

    const errorVote = await kycCertifier.vote({
      from: addresses[1]
    }).catch((err) => {
      assert.equal(err, "Error: VM Exception while processing transaction: revert", 'vote is not executed')
    })

  });
  it("should be init config KYCRegistry contract and should be set a new Project", async function () {

    const initKycRegistry = await kycRegistry.init(kycCertifier.address, kycProject.address);


    project = "0xad502f028cc1bf2b1639f251ba6d73cfeb75ba24c98288008e8ed5ca0205ee37"

    const setProjectfee = await kycProject.setProject(project, web3.toWei('0.4', 'ether'))

    const primaryCertifier = await kycRegistry.primaryCertifier();

    assert.strictEqual(primaryCertifier, addresses[0], 'Primary is not set')
  })
  it("should be claimed Certification for proposer. and confirmed by primaryCertifier", async function () {

    const primaryCertifier = await kycRegistry.primaryCertifier();

    const getProjectFee = await kycProject.getFeePrice(project)

    //console.log(getProjectFee)

    const submitCertificate = await kycRegistry.submitCertificate({
      from: addresses[1],
      value: web3.toWei(0.4, 'ether')
    })
    const claimAddress = newAddress
    const confirmCertificate = await kycRegistry.confirmCertificate(addresses[1], project, claimAddress, {
      from: primaryCertifier
    })

    //console.log(confirmCertificate)

    const balanceOfProposer = await kycRegistry.getBalanceOfWei(addresses[1])

    assert.strictEqual(balanceOfProposer.toNumber(), 0, 'balanceOfProposer is not 0')

  })
  it("should be correct that called contant functions", async function () {

    const primaryCertifier = await kycRegistry.primaryCertifier();

    const claimAddress = newAddress

    const certified = await kycRegistry.certified(claimAddress)

    assert.strictEqual(certified, true, 'certified is not true')

    const getCertifier = await kycRegistry.getCertifier(claimAddress)

    assert.strictEqual(getCertifier, primaryCertifier, 'Certifier is not primaryCertifier')

    const certifiedFrom = await kycRegistry.certifiedFrom(primaryCertifier, claimAddress)

    assert.strictEqual(certifiedFrom, true, 'certifiedFrom is not true')
  })

})