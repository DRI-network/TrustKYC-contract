const KYCCertifier = artifacts.require("./KYCCertifier.sol");
const KYCRegistry = artifacts.require("./KYCRegistry.sol");
const KYCToken = artifacts.require("./KYCToken.sol")
const KYCProject = artifacts.require("./KYCProject.sol")

module.exports = async function (deployer, network, accounts) {

  //if (network === "development") return; // Don't deploy on tests

  deployer.deploy(KYCToken).then(() => {
    return deployer.deploy(KYCRegistry)
  }).then(() => {
    return deployer.deploy(KYCProject)
  }).then(() => {
    return deployer.deploy(KYCCertifier)
  }).then(async() => {
    // certifiers
    const addresses = [
      accounts[0],
      accounts[1],
      accounts[2]
    ]

    const kycToken = await KYCToken.deployed()
    const kycRegistry = await KYCRegistry.deployed()
    const kycCertifier = await KYCCertifier.deployed()
    const kycProject = await KYCProject.deployed()

    const dist1 = await kycToken.transfer(addresses[1], web3.toWei(250000, 'ether'))
    const dist2 = await kycToken.transfer(addresses[2], web3.toWei(250000, 'ether'))

    const init = await kycCertifier.init(kycToken.address, addresses, {
      from: accounts[0]
    }).catch((err) => {
      console.log(err)
    })

    const setConfig = await kycRegistry.init(kycCertifier.address, kycProject.address)
  })
};