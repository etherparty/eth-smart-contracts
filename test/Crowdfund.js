const BigNumber = require('bignumber.js');
var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");
const utils = require("./utils")

contract('Crowdfund', function(accounts) {

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



  it("Init: The contract is initialized with the right variables", async () =>  {

    const crowdfund = await Crowdfund.new(owner, [3, 4, 5, 8], [1000, 750, 500, 250],receivingAccount,
      forwardAddress, false, 0, twentyEightDaysInSeconds, [forwardAddress, customer5,customer4, customer2, customer1, "0x0"], [100000, 100,1, 2, 3, 4], [0, 100000000, 1212, 3332, 33233, 0], {from: owner, gas: gasAmount})
    const token = await Token.at(await crowdfund.token());

    const weiRaised = await crowdfund.weiRaised();
    const crowdfundFinalized = await crowdfund.crowdfundFinalized();
    const wallet = await crowdfund.wallet();
    const forwardTokensTo = await crowdfund.forwardTokensTo();
    const crowdfundLength = await crowdfund.crowdfundLength();
    const startsAt = await crowdfund.contract.startsAt();
    const endsAt = await crowdfund.contract.endsAt();
    const totalDays = await crowdfund.contract.totalDays();
    const crowdfundOwner = await crowdfund.owner();
    const tokenOwner = await token.owner();


    assert.equal(weiRaised.eq(0), true, "The contract ether balance was not 5 ETH");
    assert.equal(wallet, receivingAccount, "The receiving account should be the wallet");
    assert.equal(forwardTokensTo, forwardAddress, "The forward address should match");
    assert.equal(crowdfundLength.eq(twentyEightDaysInSeconds), true, "The crowdfund length should match");
    assert.equal(totalDays.eq(28), true, "Total days should match");
    assert.equal(crowdfundOwner, owner, "Crowdfund Owner should match");
    assert.equal(tokenOwner, owner, "Token owner should match");
    assert.equal(startsAt.toNumber(), Math.round(Date.now() / 1000), "StartsAt should match");
    assert.equal(endsAt.toNumber(), Math.round(Date.now() / 1000 + twentyEightDaysInSeconds), "EndsAt should match");

  });
});