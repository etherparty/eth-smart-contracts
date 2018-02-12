const BigNumber = require('bignumber.js');
var Crowdfund = artifacts.require("./Crowdfund.sol");
var Token = artifacts.require("./Token.sol");
const utils = require("./utils")

contract('Token', function(accounts) {

  const owner = accounts[0];
  const receivingAccount = accounts[1];
  const customer1 = accounts[2];
  const customer2 = accounts[3];
  const customer3 = accounts[4];
  const customer4 = accounts[5];
  const customer5 = accounts[6]


  it("Should work", async () =>  {


  });

});
