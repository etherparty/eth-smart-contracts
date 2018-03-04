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
    const epochs = [3, 4, 5, 8]
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
        {from: owner, gas: 4400000}
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
      // check rates, weiraised, isactivated, starts at, ends ast....

    assert.equal(weiRaised.eq(0), true, "The contract ether balance was not 5 ETH");
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

  // Test startcrowdfund, happy and unhappy path
  // rates per epoch
  // function changeForwardAddress(address _forwardTokensTo) public onlyOwner nonZeroAddress(_forwardTokensTo) {
  // function changeWalletAddress(address _wallet) public onlyOwner nonZeroAddress(_wallet) {
  // function buyTokens(address _to) public crowdfundIsActive nonZeroAddress(_to) nonZeroValue payable {
  // function closeCrowdfund() external onlyAfterCrowdfund onlyOwner returns (bool success) {
  // function getRate() public constant returns (uint price) { // This one is dynamic, would have multiple rounds
  // function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyBeforeCrowdfund onlyOwner returns (bool success) {
  // function kill() external onlyOwner {
  // function () external payable {
});