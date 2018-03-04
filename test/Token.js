const BigNumber = require('bignumber.js');
var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");

const utils = require("./utils")

contract('Token', function(accounts) {

  function bigNumberize(num, decimals) {
    return new BigNumber(num).times(new BigNumber(10).pow(decimals));
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
  const allocationTimelocks = [0, 1520121530, 1520121530, 1520121530, 1520121530, 0]
  const totalSupply_ = 1000000


  it("Init: The contract is initialized with the right variables", async () =>  {
    Crowdfund.class_defaults.gas = 4000000
    const crowdfund = await Crowdfund.new(
      owner,
      epochs,
      prices,
      receivingAccount,
      forwardAddress,
      totalDays,
      totalSupply_,
      allocationAddresses,
      allocationBalances,
      allocationTimelocks,
      {from: owner, gas: 4400000}
    )
    const token = await Token.at(await crowdfund.token());

    const name = await token.name();
    const symbol = await token.symbol();
    const decimals = await token.decimals();
    const crowdfundAddress = await token.crowdfundAddress();
    const tokensLocked = await token.tokensLocked();
    const tokenOwner = await token.owner();
    const totalSupply = await token.totalSupply();

    assert.equal(name, "NAME", "The contract has the right name");
    assert.equal(symbol, "SYMBOL", "The contract has the right symbol");
    assert.equal(decimals, 18, "The contract has the right decimals");
    assert.equal(crowdfundAddress, crowdfund.address, "The contract has the right crowdfund address");
    assert.equal(tokensLocked, true, "Tokens are locked");
    assert.equal(owner, tokenOwner, "Owner is the right account");
    assert.equal(totalSupply.eq(totalSupply_), true, "Total supply is equal");

    for (var i = 0; i < allocationBalances.length; i++) {
      let address = allocationAddresses[i]
      if (address === '0x0') {
        address = crowdfundAddress
      }
      let allocations = await token.allocations(address);
      assert.equal(allocations[0].eq(bigNumberize(allocationBalances[i], 18)), true,  "Allocation balance is right");
      assert.equal(allocations[1].eq(allocationTimelocks[i]), true, "Allocation timelock is right");
    }
  });

  // Test transfers -- Locking + unlocking
  // Test transferFrom -- Locking + unlocking
  // Test moveAllocation -- happy + unhappy path
  // Lock and unlock tokens
});
