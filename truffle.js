module.exports = {
  networks: {
    development: {
    	host: 'localhost',
    	port: 8545,
    	network_id: '*',
      gas: 4612386
    }, 
    ropsten: {
      host: 'https://ropsten.infura.io/VYHM28f6EsD7dSXSHcmM',
      port: 8545,
      network_id: 3,
      gas: 4612386
    },
    rinkeby: {
      host: 'localhost',
      port: 8545,
      gas: 4612386,
      network_id: 4
    },
    live: {
      host: 'localhost',
      port: 8545,
      network_id: 1
    },
    rootstock: {
      host: '192.241.219.58',
      from: '0xca5464cec998782f57520ae08e8ad72dec3f4cab',
      gas: 5000000,
      gasPrice: 1,
      // port: 80,
      network_id: "*"
    },
    rootstockLocal: {
      host: 'localhost',
      port: 4444,
      gas: 2500000,
      gasPrice: 2500000000,
      // port: 80,
      network_id: "*"
    },
    devLocal: {
      host: '138.197.137.83',
      port: 80,
      // port: 80,
      network_id: "*"
    }
  }
}
