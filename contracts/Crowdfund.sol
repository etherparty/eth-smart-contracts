pragma solidity ^0.4.15;

import "./zeppelin-solidity/SafeMath.sol";
import "./zeppelin-solidity/CanReclaimToken.sol";
import "./helpers/NonZero.sol";
import "./Token.sol";

contract Crowdfund is NonZero, CanReclaimToken {

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

    uint256 totalWeeks = crowdfundLength / 1 weeks;

    uint256[10] public rateArray = [3000, 2250, 1700, 1275]; //  {{.RateArray}}

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
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     */
    function Crowdfund(address _owner) internal {

        if (!userActivated) {
            // Either we start the crowdfund now, or later on.
            startCrowdfund();
        }
        // Change the owner to the owner address.
        owner = _owner;
        token = new Token(owner); // Create new Token
    }

    /**
     * @dev Called by the owner or the contract at the start of the crowdfund
     */
    function startCrowdfund() public {
        require(isReadyToActivate == false && (msg.sender == address(this) || msg.sender == owner));
            startsAt = now;
            endsAt = startsAt + crowdfundLength;
            isReadyToActivate = true;
            assert(startsAt > now && startsAt < endsAt && endsAt > now);
    }

    /**
     * @dev Change the main contribution wallet
     * @param _wallet The new contribution wallet address
     */
    function changeWalletAddress(address _wallet) onlyOwner public {
        wallet = _wallet;
        WalletAddressChanged(_wallet);
    }

    /**
     * @dev Buys tokens at the current rate
     * @param _to The address the bought tokens are sent to
     */
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

    /**
     * @dev Closes the crowdfund only after the crowdfund ends and by the owner
     * @return bool True if closed successfully else false
     */
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

    /**
     * @dev Returns token rate depending on the current time
     * @return uint The price of the token rate per 1 ETH
     */
    function getRate() public constant returns (uint price) { // This one is dynamic, would have multiple rounds
        uint256 weeksLeft = (crowdfundLength - now) / 1 weeks;

        // currentWeek = totalWeeks - weeksLeft
        return rateArray[totalWeeks - weeksLeft];

    }

    /**
     * @dev Sends presale tokens to any contributors when called by the owner
     * @param _batchOfAddresses An array of presale contributor addresses
     * @param _amountOfTokens An array of tokens bought synchronized with the index value of _batchOfAddresses
     * @return bool True if successful else false
     */
    function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyOwner returns (bool success) {
        for (uint256 i = 0; i < _batchOfAddresses.length; i++) {
            deliverPresaleToken(_batchOfAddresses[i], _amountOfTokens[i]);
        }
        return true;
    }

    /**
     * @dev Sends token to presale address
     * @param _accountHolder Account address to send token to
     * @param _amountOfTokens Amount of tokens to send
     */
    // All presale purchases will be delivered.
    function deliverPresaleToken(address _accountHolder, uint256 _amountOfTokens) internal {
        if (!token.moveAllocation(_accountHolder, _amountOfTokens)) {
            revert();
        }
    }

    /**
     * @dev Called by the owner to kill the contact once the crowdfund is finished and there are no tokens left
     */
    function kill() onlyOwner external {
        var (,amount,) = token.allocations(this);
        require(crowdfundFinalized == true && amount == 0);
        selfdestruct(owner);
    }

    /**
     * @dev Allows for users to send ETH to buy tokens
     */
    function () payable external {
        buyTokens(msg.sender);
    }
}
