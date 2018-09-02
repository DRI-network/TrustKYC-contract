module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "33", // Match any network id
      gas: 4700000
    },
    testnet: {
      host: "192.168.0.103",
      port: 8545,
      network_id: 3, // Match ropsten network id
      gas: 4700036,
      gasPrice: 15000000000
    }
  }
};