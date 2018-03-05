const BigNumber = require('bignumber.js');
var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");
const utils = require("./utils")

contract('Crowdfund', function(accounts) {

  function bigNumberize(num, decimals) {
    return new BigNumber(num).times(new BigNumber(10).pow(decimals));
  }

  async function jumpToTheFuture(seconds) {
    return web3.currentProvider.send({jsonrpc: "2.0", method: "evm_increaseTime", params: [seconds], id: 0});
  }

  async function getTimestampOfCurrentBlock() {
    return web3.eth.getBlock(web3.eth.blockNumber).timestamp;
  }

  function isException(error) {
    let strError = error.toString();
    return strError.includes('invalid opcode') || strError.includes('invalid JUMP') || strError.includes("revert");
  }

  function ensureException(error) {
    assert(isException(error), error.toString());
  }

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
    const prices = [1000, 750, 500, 250]
    const epochs = [3, 4, 7, 14]
    const totalDays = 28
    const allocationAddresses = [forwardAddress, customer5,customer4, customer2, customer1, "0x0"]
    const allocationBalances = [50000, 100000,50000, 200000, 100000, 500000]
    const allocationTimelocks = [0, 100000000, 1212, 3332, 33233, 0]
    const totalSupply = 1000000

    it("Init: The contract is initialized with the right variables", async () =>  {
      Crowdfund.class_defaults.gas = 4000000
      const crowdfund = await Crowdfund.new(
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks,
        {from: owner, gas: 5000000}
      )
    const token = await Token.at(await crowdfund.token());

    const weiRaised = await crowdfund.weiRaised();
    const crowdfundFinalized = await crowdfund.crowdfundFinalized();
    const wallet = await crowdfund.wallet();
    const forwardTokensTo = await crowdfund.forwardTokensTo();
    const crowdfundLength = await crowdfund.crowdfundLength();
    const startsAt = await crowdfund.contract.startsAt();
    const endsAt = await crowdfund.contract.endsAt();
    const daysTotal = await crowdfund.contract.totalDays();
    const crowdfundOwner = await crowdfund.owner();
    const tokenOwner = await token.owner();
    const crowdfundAllocation = await token.allocations(crowdfund.address)
    const isActivated = await crowdfund.isActivated()

    let totalEpochs = 0
    for (var i = 0; i < epochs.length; i++) {
      let price =  await crowdfund.rates(i)
      totalEpochs += epochs[i]
      assert.equal(price[0].eq(prices[i]), true,  "Price at a certain epoch is right");
      assert.equal(price[1].eq(totalEpochs), true, "Passed in epochs are right");
    }

    assert.equal(weiRaised.eq(0), true, "The contract ether balance was not 5 ETH");
    assert.equal(isActivated, false, "The crowdfund is not activated");
    assert.equal(wallet, receivingAccount, "The receiving account should be the wallet");
    assert.equal(forwardTokensTo, forwardAddress, "The forward address should match");
    assert.equal(crowdfundLength.eq(twentyEightDaysInSeconds), true, "The crowdfund length should match");
    assert.equal(daysTotal.eq(28), true, "Total days should match");
    assert.equal(crowdfundOwner, owner, "Crowdfund Owner should match");
    assert.equal(tokenOwner, owner, "Token owner should match");
    assert.equal(startsAt.toNumber(), 0, "StartsAt should match");
    assert.equal(endsAt.toNumber(), 0, "EndsAt should match");
    assert.equal(crowdfundAllocation[0].eq(bigNumberize(allocationBalances[allocationBalances.length - 1],18)), true,  "Crowdfund Allocation balance is right");
    assert.equal(crowdfundAllocation[1].eq(allocationTimelocks[allocationBalances.length - 1]), true, "Crowdfund Allocation timelock is right");

  });

    it("Schedule and Reschedule crowdfund: It should schedule the crowdfund and not let me reschedule after the crowdfund is active", async () =>  {
      Crowdfund.class_defaults.gas = 4000000
      const crowdfund = await Crowdfund.new(
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks,
        {from: owner, gas: 5000000}
      )
    const token = await Token.at(await crowdfund.token());

    // First try to schedule the crowdfund in the past
    let errorSchedule = await getTimestampOfCurrentBlock() - 120
    try {
      await crowdfund.scheduleCrowdfund(errorSchedule)
    } catch(e) {
      ensureException(e)
    }
    assert.equal((await crowdfund.startsAt()).eq(bigNumberize(0, 18)), true, "Should equal 0")
    assert.equal((await crowdfund.endsAt()).eq(bigNumberize(0, 18)), true, "Should equal 0")

    // Now schedule the crowdfund for 2 minutes in the futures
    let firstSchedule = await getTimestampOfCurrentBlock() + 120

    // We can schedule the crowdfund first, not reschedule it
    try {
      await crowdfund.reScheduleCrowdfund(firstSchedule)
    } catch (e) {
      ensureException(e)
    }

    // call schedule crowdfund NOT from the owner
    try {
      await crowdfund.scheduleCrowdfund(firstSchedule, {from: customer1})
    } catch (e) {
      ensureException(e)
    }

    await crowdfund.scheduleCrowdfund(firstSchedule)

    // Buying tokens should fail
    try {
      await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')} )
    } catch(e) {
      ensureException(e)
    }
    assert.equal((await token.balanceOf(owner)).eq(bigNumberize(0, 0)), true, "Should equal")
    assert.equal((await crowdfund.startsAt()).eq(bigNumberize(firstSchedule, 0)), true, "Should equal the firstSchedule")
    assert.equal((await crowdfund.endsAt()).eq(bigNumberize(firstSchedule + totalDays*24*60*60, 0)), true, "Should equal days total added")

    // We can still reschedule the crowdfund
    let secondSchedule = await getTimestampOfCurrentBlock() + 240

    // call reScheduleCrowdfund NOT from the owner
    try {
      await crowdfund.reScheduleCrowdfund(secondSchedule, {from: customer1})
    } catch (e) {
      ensureException(e)
    }
    await crowdfund.reScheduleCrowdfund(secondSchedule)

    assert.equal((await crowdfund.startsAt()).eq(bigNumberize(secondSchedule, 0)), true, "Should equal the secondSchedule")
    assert.equal((await crowdfund.endsAt()).eq(bigNumberize(secondSchedule + totalDays*24*60*60, 0)), true, "Should equal days total added II")

    // We can reschedule, but not schedule the crowdfund
    try {
      await crowdfund.scheduleCrowdfund(secondSchedule)
    } catch(e) {
      ensureException(e)
    }

    // Jump more than 4 minutes -- we are in the crowdfund
    jumpToTheFuture(360)
    let thirdSchedule = await getTimestampOfCurrentBlock() + 240

    // Cannot schedule or reschedule crowdfund after crowdfund started
    try {
      await crowdfund.scheduleCrowdfund(thirdSchedule)
    } catch(e) {
      ensureException(e)
    }

    try {
      await crowdfund.scheduleCrowdfund(thirdSchedule)
    } catch(e) {
      ensureException(e)
    }
  });

    it("Rates per epoch: It should return the right price when buying tokens", async () =>  {
      Crowdfund.class_defaults.gas = 4000000
      const crowdfund = await Crowdfund.new(
        owner,
        epochs,
        prices,
        receivingAccount,
        forwardAddress,
        totalDays,
        totalSupply,
        allocationAddresses,
        allocationBalances,
        allocationTimelocks,
        {from: owner, gas: 5000000}
      )
    const token = await Token.at(await crowdfund.token());

    let startDate = await getTimestampOfCurrentBlock() + 100
    await crowdfund.scheduleCrowdfund(startDate)
      // Buying tokens should fail
    try {
      await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')} )
    } catch(e) {
      ensureException(e)
    }
    assert.equal((await token.balanceOf(owner)).eq(bigNumberize(0, 0)), true, "Should equal 0")

    await jumpToTheFuture(500)
    try {
      await crowdfund.changeWalletAddress(owner, {from: owner})
    } catch(e) {
      ensureException(e)
    }

    let totalPrices = 0;
    let totalEpochs = 0;
    for (var i = 0 ; i < epochs.length; i++) {
      let rate = await crowdfund.rates(i)
      let currentRate = await crowdfund.getRate()
      totalEpochs += epochs[i]
      assert.equal((rate[0]).eq(bigNumberize(prices[i], 0)), true, "Rates should equal")
      assert.equal((rate[1]).eq(bigNumberize(totalEpochs, 0)), true, "Epochs should equal")
      totalPrices += prices[i]
      await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')})
      assert.equal((await token.balanceOf(owner)).eq(bigNumberize(totalPrices, 18)), true, "Should equal")
      await jumpToTheFuture(epochs[i] * 24*60*60 + 5000)
      // to adjust the next block
      await crowdfund.changeWalletAddress(owner, {from: owner})
    }


  });

  // function changeForwardAddress(address _forwardTokensTo) public onlyOwner nonZeroAddress(_forwardTokensTo) {
  // function changeWalletAddress(address _wallet) public onlyOwner nonZeroAddress(_wallet) {
  // function buyTokens(address _to) public crowdfundIsActive nonZeroAddress(_to) nonZeroValue payable {
  // function closeCrowdfund() external onlyAfterCrowdfund onlyOwner returns (bool success) {
  // function getRate() public constant returns (uint price) { // This one is dynamic, would have multiple rounds
  // function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyBeforeCrowdfund onlyOwner returns (bool success) {
  // function kill() external onlyOwner {
  // function () external payable {
});