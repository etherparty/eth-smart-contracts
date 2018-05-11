
module.exports = {
    addSeconds: (web3, seconds) => {
        return web3
            .currentProvider
            .send({jsonrpc: "2.0", method: "evm_increaseTime", params: [seconds], id: 0});
    },

    fromBigNumberWeiToEth: (bigNum) => {
        return bigNum
            .dividedBy(new BigNumber(10).pow(18))
            .toNumber();
    },

    getTimestampOfCurrentBlock: (web3) => {
        return web3
            .eth
            .getBlock(web3.eth.blockNumber)
            .timestamp;
    },
    oneWeekInSeconds: 604800
}