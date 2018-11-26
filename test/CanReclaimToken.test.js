const { assertRevert } = require('./helpers/assertRevert');

var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");
var FailingTokenMock = artifacts.require("mocks/ERC20FailingMock.sol");

require('chai')
    .use(require('chai-as-promised'))
    .should();

contract('CanReclaimToken', function (accounts) {
    const gasAmount = 6000000;
    const owner = accounts[0];
    const receivingAccount = accounts[1];
    const forwardAddress = accounts[7]
    const customer1 = accounts[2];
    const customer2 = accounts[3];
    const customer3 = accounts[4];
    const customer4 = accounts[5];
    const customer5 = accounts[6]

    const twentyEightDaysInSeconds = 2419200;
    const prices = [1000, 750, 500, 250] // 1*10^18 * 1000
    const epochs = [3, 4, 7, 14]
    const totalDays = 28
    const allocationAddresses = [forwardAddress, customer5, customer4, customer2, customer1, "0x0"]
    const allocationBalances = [
        50000000000000000000000,
        100000000000000000000000,
        50000000000000000000000,
        200000000000000000000000,
        100000000000000000000000,
        500000000000000000000000
    ]
    const allocationTimelocks = [0, twentyEightDaysInSeconds, 10 * 24 * 60 * 60, 10 * 24 * 60 * 60, 15 * 24 * 60 * 60, 0]
    const totalSupply_ = 1000000000000000000000000
    const withCrowdfund = false
    const crowdfundArgs = [
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply_,
        withCrowdfund,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks
    ]


    it("Should be able to reclaim tokens", async () => {
        let tokenArguments = [
            owner,
            100,
            [owner, accounts[2], accounts[3]],
            [50, 30, 20],
            [0,0,0]
        ]


        let firstToken = await Token.new(...tokenArguments, {from: owner});
        let crowdfund = await Crowdfund.new(...crowdfundArgs, {from: owner});
        let failingToken = await FailingTokenMock.new({from: owner});

        await firstToken.changeCrowdfundStartTime(10, {from: owner});
        await firstToken.unlockTokens({from: owner});

        assert.equal(await firstToken.balanceOf(owner), 0, "Should have intialized to zero tokens")
        assert.equal(await firstToken.balanceOf(crowdfund.address), 0, "Should have intialized to zero tokens")

        await firstToken.moveAllocation(crowdfund.address, 10);
        assert.equal(await firstToken.balanceOf(crowdfund.address), 10, "Should have intialized to zero tokens")

        await crowdfund.reclaimToken(failingToken.address, {from: owner}).should.be.rejectedWith('invalid opcode');;

        await crowdfund.reclaimToken(firstToken.address, {from: owner});
        assert.equal(await firstToken.balanceOf(owner), 10, "Should have intialized to zero tokens")

    });

});
