pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./helpers/NonZero.sol";
import "./Token.sol";

contract Crowdfund is NonZero, Ownable {

    using SafeMath for uint;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////

    // Address of the deployed FUEL Token contract
    address public tokenAddress;
    // Amount of wei currently raised
    uint256 public weiRaised = 0;
    // UNIX timestamp of when the crowdfund starts
    uint256 public startsAt;
    // UNIX timestamp of when the crowdfund ends
    uint256 public endsAt;
    // Instance of the Fuel token contract
    Token public token;
    // Whether the crowdfund is in a "Ready to activate" state
    bool private isReadyToActivate = false;
    // Flag keeping track of crowdsale status. Ensures functions can only be called once
    bool public crowdfundFinalized = false;


    // Our own vars
    // Whether the user wants to start the crowdfund
    bool private userActivated = false; // {{.UserActivated}}
    // Address of secure wallet to send crowdfund contributions to
    address public wallet = 0x0; // {{.WalletAddress}}

    address public finalAddress = 0x0; // {{.FinalAddress}}

    uint256 public crowdfundLength; // {{.CrowdfundLength}}

/////////////////////// EVENTS ///////////////////////

    // Emitted upon owner changing the wallet address
    event WalletAddressChanged(address _wallet);
    // Emmitted upon purchasing tokens
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

/////////////////////// MODIFIERS ///////////////////////

    // Ensure the crowdfund is ongoing
    modifier crowdfundIsActive() {
        assert(now >= startsAt && now <= endsAt);
        _;
    }

    // Ensure actions can only happen after crowdfund ends
    modifier notBeforeCrowdfundEnds() {
        require(now >= endsAt);
        _;
    }

/////////////////////// CROWDFUND FUNCTIONS ///////////////////////
    // Constructor
    function Crowdfund(address _owner) internal {

        if (!userActivated) {
            // Either we start the crowdfund now, or later on.
            startCrowdfund();
        }
        // Change the owner to the owner address.
        owner = _owner;
        token = new Token(owner); // Create new Token
    }

    function startCrowdfund() public { // Either called by the owner, or the contract itself
        require(isReadyToActivate == false && (msg.sender == address(this) || msg.sender == owner));
            startsAt = now;
            endsAt = now + crowdfundLength;
            isReadyToActivate = true;
            assert(startsAt > now && startsAt < endsAt && endsAt > now);
    }

    // Change main contribution wallet
    function changeWalletAddress(address _wallet) onlyOwner public {
        wallet = _wallet;
        WalletAddressChanged(_wallet);
    }


    // Function to buy. One can also buy by calling this function directly and send it to another destination.
    function buyTokens(address _to) crowdfundIsActive nonZeroAddress(_to) nonZeroValue payable public {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount * getRate();
        weiRaised = weiRaised.add(weiAmount);
        wallet.transfer(weiAmount);
        if (!token.moveAllocation(_to, tokens)) {
            revert();
        }
        TokenPurchase(_to, weiAmount, tokens);
    }

    // Function to close the crowdfund. Only function to unlock the tokens
    function closeCrowdfund() external notBeforeCrowdfundEnds onlyOwner returns (bool success) {
        require(crowdfundFinalized == false);
        var (,amount,) = token.allocations(this);
        if (amount > 0) {
            // Transfer all of the tokens out to the final address (if burning, send to 0x0)
            if (!token.moveAllocation(finalAddress, amount)) {
                revert();
            }
        }
        // Unlock the tokens
        if (!token.unlockTokens()) {
            revert();
        }
        crowdfundFinalized = true;
        return true;
    }

/////////////////////// CONSTANT FUNCTIONS ///////////////////////

    // Returns FUEL disbursed per 1 ETH depending on current time
    function getRate() public constant returns (uint price) { // This one is dynamic, would have multiple rounds
        if (now > (startsAt + 3 weeks)) {
           return 1275; // week 4
        } else if (now > (startsAt + 2 weeks)) {
           return 1700; // week 3
        } else if (now > (startsAt + 1 weeks)) {
           return 2250; // week 2
        } else {
           return 3000; // week 1
        }

    /*
    ** pseudo-code
        for var i := 0 ; i < len(prices); i++ {
            if i == 0 {
                `if (now > (startsAt + len(prices) weeks)) {
                    return prices[i];
                } `
            } else if i < len(prices) -2 {
                `else if (now > (startsAt + len(prices) weeks)) {
                    return prices[i];
                } `
            } else {
                `else {
                    return prices[i];
                }`
            }

        }
            `
     */
    }

    // Function to send Tokens to presale investors
    function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyOwner returns (bool success) {
        for (uint256 i = 0; i < _batchOfAddresses.length; i++) {
            deliverPresaleToken(_batchOfAddresses[i], _amountOfTokens[i]);
        }
        return true;
    }

    // All presale purchases will be delivered.
    function deliverPresaleToken(address _accountHolder, uint256 _amountOfTokens) internal {
        if (!token.moveAllocation(_accountHolder, _amountOfTokens)) {
            revert();
        }
    }

    function kill() onlyOwner external {
        var (,amount,) = token.allocations(this);
        require(crowdfundFinalized == true && amount == 0);
        selfdestruct(owner);
    }


    // To contribute, send a value transaction to the Crowdfund Address. Please include at least 100 000 gas.
    function () payable external {
        buyTokens(msg.sender);
    }
}