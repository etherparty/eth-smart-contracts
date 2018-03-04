const BigNumber = require('bignumber.js');
var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");

const utils = require("./utils")

contract('Token', function(accounts) {

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
  const prices = [1000, 750, 500, 250] // 1*10^18 * 1000
  const epochs = [3, 4, 5, 8]
  const totalDays = 28
  const allocationAddresses = [forwardAddress, customer5,customer4, customer2, customer1, "0x0"]
  const allocationBalances = [50000, 100000,50000, 200000, 100000, 500000] // 500000 * 10^18
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
    assert.equal(totalSupply.eq(bigNumberize(totalSupply_, 18)), true, "Total supply is equal");

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


  it("Transfer: It tests the transfer function", async () =>  {
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

    try {
      await token.transfer(customer1, web3.toWei(2, 'ether'), {from: owner})
    } catch(e) {
      ensureException(e)
    }
    // Start the crowdfund now
    await crowdfund.startCrowdfund(await getTimestampOfCurrentBlock(), {from: owner})

    assert.equal(await crowdfund.isActivated(), true, "Crowdfund should be active")
    // Buy tokens
    await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')} )

    assert.equal((await token.balanceOf(owner)).eq(bigNumberize(250, 18)), true, "Should equal")

    try {
      await token.transfer(customer1, web3.toWei(2, 'ether'), {from: owner})
    } catch(e) {
      ensureException(e)
    }
    // Jump in the future
    await jumpToTheFuture(totalDays*24*60*60 + 20000)
    // close the crowdfund
    await crowdfund.closeCrowdfund({from: owner})

    assert.equal(await crowdfund.crowdfundFinalized(), true, "Crowdfund should NOT be active")

    assert.equal(await token.tokensLocked(), false, "Tokens should be unlocked")

    await jumpToTheFuture(20000)

    await token.transfer(customer1, web3.toWei(2, 'ether'), {from: owner})

    assert.equal((await token.balanceOf(customer1)).eq(bigNumberize(2, 18)), true, "Should equal")

  });

    // function transferFrom(address _from, address _to, uint256 _amount) public onlyUnlocked returns (bool success) {
  // function approve(address _spender, uint256 _value) public returns (bool) {
  // function allowance(address _owner, address _spender) public view returns (uint256) {

  it("TransferFrom: It tests the transferFrom function", async () =>  {
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

    await token.approve(customer1, web3.toWei(2, 'ether'), {from: owner})
    try {
      await token.transferFrom(owner, customer1, web3.toWei(2, 'ether'), {from: customer1})
    } catch(e) {
      ensureException(e)
    }
    // Start the crowdfund now
    await crowdfund.startCrowdfund(await getTimestampOfCurrentBlock(), {from: owner})

    assert.equal(await crowdfund.isActivated(), true, "Crowdfund should be active")
    // Buy tokens
    await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')} )

    assert.equal((await token.balanceOf(owner)).eq(bigNumberize(250, 18)), true, "Should equal")

    try {
      await token.transferFrom(owner, customer1, web3.toWei(2, 'ether'), {from: customer1})
    } catch(e) {
      ensureException(e)
    }
    // Jump in the future
    await jumpToTheFuture(totalDays*24*60*60 + 20000)
    // close the crowdfund
    await crowdfund.closeCrowdfund({from: owner})

    assert.equal(await crowdfund.crowdfundFinalized(), true, "Crowdfund should NOT be active")

    assert.equal(await token.tokensLocked(), false, "Tokens should be unlocked")

    await jumpToTheFuture(20000)

    await token.transferFrom(owner, customer1, web3.toWei(2, 'ether'), {from: customer1})

    assert.equal((await token.balanceOf(customer1)).eq(bigNumberize(2, 18)), true, "Should equal")

  });

  it("MoveAllocation: It tests the moveAllocation function", async () =>  {

    currentTime = await getTimestampOfCurrentBlock()
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
      [0, currentTime + twentyEightDaysInSeconds, currentTime + 10*24*60*60, currentTime + 10*24*60*60, 15*24*60*60 , 0],
      {from: owner, gas: 4400000}
    )
    const token = await Token.at(await crowdfund.token());

    // First allocation can move (timelock of 0)
    await token.moveAllocation(customer5, web3.toWei(1, 'ether'), {from: forwardAddress})
    assert.equal((await token.balanceOf(customer5)).eq(bigNumberize(1, 18)), true, "Should equal")

    // Second allocation cannot move (timelock of 28 days)
    try {
      await token.moveAllocation(customer4, web3.toWei(1, 'ether'), {from: customer5})
    } catch(e) {
      ensureException(e)
    }
    assert.equal((await token.balanceOf(customer4)).eq(0), true, "Should equal")

    // Third allocation cannot move, only after 10 days
      try {
        await token.moveAllocation(customer3, web3.toWei(1, 'ether'), {from: customer4})
      } catch(e) {
        ensureException(e)
      }
      assert.equal((await token.balanceOf(customer3)).eq(0), true, "Should equal")

      await jumpToTheFuture(10*24*60*60 + 20000)
      await token.moveAllocation(customer3, web3.toWei(1, 'ether'), {from: customer4})
      assert.equal((await token.balanceOf(customer3)).eq(web3.toWei(1, 'ether')), true, "Should equal")

    // Start the crowdfund now
    await crowdfund.startCrowdfund(await getTimestampOfCurrentBlock(), {from: owner})

    assert.equal(await crowdfund.isActivated(), true, "Crowdfund should be active")
    // Buy tokens (Means the crowdfund allocation works)
    await crowdfund.buyTokens(owner, {from: owner, value: web3.toWei('1', 'ether')})
    assert.equal((await token.balanceOf(owner)).eq(bigNumberize(250, 18)), true, "Should equal")
    assert.equal((await token.allocations(crowdfund.address))[0].eq((await token.crowdfundSupply()).minus(bigNumberize(250, 18))), true, "Should equal")

    // Move all allocation from a specific allocation
    await jumpToTheFuture(twentyEightDaysInSeconds + 20000)

    await token.moveAllocation(accounts[7], (await token.allocations(customer2))[0], {from: customer2})
    assert.equal((await token.balanceOf(accounts[7])).eq(bigNumberize(200000, 18)), true, "Should equal")
    try {
      await token.moveAllocation(owner, '1', {from: customer2})
    } catch(e) {
      ensureException(e)
    }

    // Try to get an allocation from an account that does not have one
    try {
      await token.moveAllocation(owner, '1', {from: accounts[8]})
    } catch(e) {
      ensureException(e)
    }
  });
});
