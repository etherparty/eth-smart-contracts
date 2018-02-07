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
    // Address of secure wallet to send crowdfund contributions to
    address public wallet;

    // Amount of wei currently raised
    uint256 public weiRaised = 0;
    // UNIX timestamp of when the crowdfund starts
    uint256 public startsAt;
    // UNIX timestamp of when the crowdfund ends
    uint256 public endsAt;

    // Instance of the Fuel token contract
    Token public token;

/////////////////////// EVENTS ///////////////////////

    // Emitted upon owner changing the wallet address
    event WalletAddressChanged(address _wallet);
    // Emitted upon crowdfund being finalized
    event AmountRaised(address beneficiary, uint amountRaised);
    // Emmitted upon purchasing tokens
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

/////////////////////// MODIFIERS ///////////////////////

    // Ensure the crowdfund is ongoing
    modifier crowdfundIsActive() {
        assert(now >= startsAt && now <= endsAt);
        _;
    }

    // Ensure actions can only happen after crowdfund ends
    modifier notBeforeCrowdfundEnds(){
        require(now >= endsAt);
        _;
    }


/////////////////////// CROWDFUND FUNCTIONS ///////////////////////

    // Constructor
    function Crowdfund(address _tokenAddress)  public {
        wallet = 0x45d75330a9ba60c3ca01defac938be235acfdc07;    // Etherparty Wallet Address
        startsAt = now;                                  // Oct 1 2017, 9:00 AM PDT
        endsAt = now + 28 days;                                // ~4 weeks / 28 days later: Oct 29, 9 AM PST
        tokenAddress = _tokenAddress;                           // FUEL token Address
        token = Token(tokenAddress);
    }

    // Change main contribution wallet
    function changeWalletAddress(address _wallet) onlyOwner  public {
        wallet = _wallet;
        WalletAddressChanged(_wallet);
    }


    // Function to buy Fuel. One can also buy FUEL by calling this function directly and send
    // it to another destination.
    function buyTokens(address _to) crowdfundIsActive nonZeroAddress(_to) nonZeroValue payable  public {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount * getRate();
        weiRaised = weiRaised.add(weiAmount);
        wallet.transfer(weiAmount);
        if (!token.transferFromCrowdfund(_to, tokens)) {
            revert();
        }
        TokenPurchase(_to, weiAmount, tokens);
    }

    // Function to close the crowdfund. Any unsold FUEL will go to the platform to be sold at 1$
    function closeCrowdfund() external notBeforeCrowdfundEnds onlyOwner returns (bool success) {
        AmountRaised(wallet, weiRaised);
        token.finalizeCrowdfund();
        return true;
    }

/////////////////////// CONSTANT FUNCTIONS ///////////////////////

    // Returns FUEL disbursed per 1 ETH depending on current time
    function getRate() public constant returns (uint price) {
        if (now > (startsAt + 3 weeks)) {
           return 1275; // week 4
        } else if (now > (startsAt + 2 weeks)) {
           return 1700; // week 3
        } else if (now > (startsAt + 1 weeks)) {
           return 2250; // week 2
        } else {
           return 3000; // week 1
        }
    }

    // To contribute, send a value transaction to the Crowdfund Address.
    // Please include at least 100 000 gas.
    function () payable  public {
        buyTokens(msg.sender);
    }
}