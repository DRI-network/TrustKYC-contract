const KYCCertifier = artifacts.require("./KYCCertifier.sol");
const KYCRegistry = artifacts.require("./KYCRegistry.sol");
const KYCToken = artifacts.require("./KYCToken.sol")
const KYCProject = artifacts.require("./KYCProject.sol");
const abi = require('ethereumjs-abi')
const rp = require('request-promise')

contract('INFURA_CALLTest', function (accounts) {

  it("should be deployed and Call deposit Balance of a address", async function () {

    const addresses = [
      accounts[0],
      accounts[1],
      accounts[2],
    ]

    kycToken = await KYCToken.new()
    kycRegistry = await KYCRegistry.new();
    kycCertifier = await KYCCertifier.new();
    kycProject = await KYCProject.new()


    const dist1 = await kycToken.transfer(addresses[1], web3.toWei(250000, 'ether'))
    const dist2 = await kycToken.transfer(addresses[2], web3.toWei(250000, 'ether'))

    const init = await kycCertifier.init(kycToken.address, addresses, {
      from: accounts[0]
    }).catch((err) => {
      console.log(err)
    })

    const initRegistry = await kycRegistry.init(kycCertifier.address, kycProject.address)

    const submitCertificate = await kycRegistry.submitCertificate({
      from: accounts[1],
      value: web3.toWei(0.4, 'ether')
    })

    const getBalance = await kycRegistry.getBalanceOfWei(accounts[1])

    assert.strictEqual(getBalance.toNumber(), Number(web3.toWei(0.4, 'ether')), 'getBalance is not correct')
    //call data for deposit ether
    var encoded = abi.simpleEncode("getBalanceOfWei(address):(uint256)", accounts[1])

    const data = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [{
          "from": accounts[1],
          "to": kycRegistry.address,
          "value": "0x0", // 2441406250
          "data": '0x' + encoded.toString('hex')
        },
        "latest"
      ],
      "id": 1
    }

    //const uri = "https://ropsten.infura.io/jWj5gvPfonuZU0LdpLzu"
    const uri = "http://localhost:9545"

    const balanceHEX = await getData(uri, data).catch((err) => {
      console.log(err)
    })
    console.log(balanceHEX)

    const number = parseInt(balanceHEX.result, 16);
    assert.strictEqual(number, Number(web3.toWei(0.4, 'ether')), 'getBalance is not correct')
  })


  it("application should be confirmed and check the claimed address", async function () {

    //console.log(newAddress.result.address)

    const project = accounts[2];

    const setPoject = await kycProject.setProject(project, web3.toWei('0.4', 'ether'))

    const claimAddress = "0xf81adf6dc486455473c41d60ec74e42dabc12b42"
    const confirmCertificate = await kycRegistry.confirmCertificate(accounts[1], project, claimAddress, {
      from: accounts[0]
    })

    const getBalance = await kycRegistry.getBalanceOfWei(accounts[1])
    assert.strictEqual(getBalance.toNumber(), Number(web3.toWei(0, 'ether')), 'getBalance is not correct')

    
    var encoded = abi.simpleEncode("certified(address):(bool)", claimAddress)

    const data = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [{
          "from": accounts[1],
          "to": kycRegistry.address,
          "value": "0x0", // 2441406250
          "data": '0x' + encoded.toString('hex')
        },
        "latest"
      ],
      "id": 1
    }

    //const uri = "https://ropsten.infura.io/jWj5gvPfonuZU0LdpLzu"
    const uri = "http://localhost:9545"

    const result = await getData(uri, data).catch((err) => {
      console.log(err)
    })
    console.log(parseInt(result.result, 16))

    const confrm = Boolean(parseInt(result.result, 16))
    assert.strictEqual(confrm, true, 'getBalance is not correct')


  })

})


getData = async(uri, data) => {
  return new Promise((resolve, reject) => {
    var options = {
      method: 'POST',
      uri: uri,
      body: data,
      json: true // Automatically stringifies the body to JSON
    };

    rp(options)
      .then(function (parsedBody) {
        resolve(parsedBody)
        // POST succeeded...
      })
      .catch(function (err) {
        reject(err)
        // POST failed...
      });
  })
}

getNewAddress = async(uri) => {
  return new Promise((resolve, reject) => {
    var options = {
      method: 'GET',
      uri: uri,
      json: true // Automatically stringifies the body to JSON
    };

    rp(options)
      .then(function (parsedBody) {
        resolve(parsedBody)
        // POST succeeded...
      })
      .catch(function (err) {
        reject(err)
        // POST failed...
      });
  })
}