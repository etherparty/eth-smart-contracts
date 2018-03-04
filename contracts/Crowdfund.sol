pragma solidity ^0.4.15;

import "./library/SafeMath.sol";
import "./library/CanReclaimToken.sol";
import "./library/NonZero.sol";
import "./Token.sol";

contract Crowdfund is NonZero, CanReclaimToken {

    using SafeMath for uint;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////

    // Amount of wei currently raised
    uint256 public weiRaised = 0;
    // UNIX timestamp of when the crowdfund starts
    uint256 public startsAt;
    // UNIX timestamp of when the crowdfund ends
    uint256 public endsAt;
    // Instance of the Fuel token contract
    Token public token;
    // Whether the crowdfund is in a "Ready to activate" state
    bool private isActivated = false;
    // Flag keeping track of crowdsale status. Ensures closeCrowdfund() and kill() can only be called once
    bool public crowdfundFinalized = false;


    // Our own vars
    // Address of secure wallet to send ETH/SBTC crowdfund contributions to
    address public wallet;
    // Address to forward the tokens to at the end of the Crowdfund
    address public forwardTokensTo;
    // Total length of the crowdfund
    uint256 public crowdfundLength;
    // Total amount of days
    uint256 public totalDays;


    struct rate {
        uint256 price;
        uint8 amountOfDays;
    }

    // Array of token rates for each epochs
    rate[] public rates;

/////////////////////// EVENTS ///////////////////////

    // Emmitted upon purchasing tokens
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

/////////////////////// MODIFIERS ///////////////////////

    // Ensure the crowdfund is ongoing
    modifier crowdfundIsActive() {
        assert(now >= startsAt && now <= endsAt);
        _;
    }

    // Ensure actions can only happen after crowdfund ends
    modifier onlyAfterCrowdfund() {
        require(now >= endsAt);
        _;
    }

    modifier onlyBeforeCrowdfund() {
        require(now <= startsAt);
        _;
    }
/////////////////////// CROWDFUND FUNCTIONS ///////////////////////
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     */
    function Crowdfund(
        address _owner,                     // Owner of the crowdfund contract
        uint8[] memory amountOfDays,        // Array of the length of epoch per specific token price (in days)
        uint256[] memory prices,            // Array of the prices for each price epoch
        address _wallet,                    // Wallet address
        address _forwardTokensTo,           // Address to forward the tokens to
        uint256 _totalDays,           // Length of the crowdfund in days
        uint256 _totalSupply,               // Total Supply of the token
        address[] memory _allocAddresses,   // Array of allocation addresses
        uint256[] memory _allocBalances,    // Array of allocation balances
        uint256[] memory _timelocks         // Array of timelocks for all the allocations
        ) public {

        wallet = _wallet;
        // Change the owner to the owner address.
        owner = _owner;
        forwardTokensTo = _forwardTokensTo;
        totalDays = _totalDays;
        crowdfundLength = _totalDays.mul(1 days);

        // Ensure the prices per epoch passed in are the same length and limit the size of the array
        assert(amountOfDays.length == prices.length && prices.length < 10);
        // Push all of them to the rates array
        for (uint8 i = 0; i < amountOfDays.length; i++) {
            rates.push(rate(prices[i], amountOfDays[i]));
        }

        // // Create the token contract
        token = new Token(owner, crowdfundLength, _totalSupply, _allocAddresses, _allocBalances, _timelocks); // Create new Token

    }

    /**
     * @dev Called by the owner or the contract at the start of the crowdfund
     * @param _startDate The start date UNIX timestamp
     */
    function startCrowdfund(uint256 _startDate) public returns(bool) {
        // require only the owner can start the crowdfund
        require(msg.sender == owner);
        // crowdfund cannot be already activated
        require(isActivated == false);
        startsAt = _startDate;
        endsAt = startsAt + crowdfundLength;
        isActivated = true;
        assert(startsAt >= now && endsAt > startsAt);
        return true;
    }

    /**
     * @dev Change the main contribution wallet
     * @param _wallet The new contribution wallet address
     */
    function changeWalletAddress(address _wallet) public onlyOwner nonZeroAddress(_wallet) {
        wallet = _wallet;
    }

    /**
     * @dev Change the main contribution wallet
     * @param _forwardTokensTo The new contribution wallet address
     */
    function changeForwardAddress(address _forwardTokensTo) public onlyOwner nonZeroAddress(_forwardTokensTo) {
        forwardTokensTo = _forwardTokensTo;
    }

    /**
     * @dev Buys tokens at the current rate
     * @param _to The address the bought tokens are sent to
     */
    function buyTokens(address _to) public crowdfundIsActive nonZeroAddress(_to) nonZeroValue payable {
        uint256 weiAmount = msg.value;
        uint256 tokens = weiAmount.mul(getRate());
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
    function closeCrowdfund() external onlyAfterCrowdfund onlyOwner returns (bool success) {
        require(crowdfundFinalized == false);
        var (amount,) = token.allocations(this);
        if (amount > 0) {
            // Transfer all of the tokens out to the final address (if burning, send to 0x0)
            if (!token.moveAllocation(forwardTokensTo, amount)) {
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
        uint256 daysPassed = totalDays - (crowdfundLength - now) / 1 days;

        for (uint8 i = 0; i < rates.length; i++) {
        // if the days passed since the start is below the amountOfdays we use the last rate
            if (daysPassed < rates[i].amountOfDays) {
                break;
            }
        }
        return rates[--i].price;
    }

    /**
     * @dev Sends presale tokens to any contributors when called by the owner
     * @param _batchOfAddresses An array of presale contributor addresses
     * @param _amountOfTokens An array of tokens bought synchronized with the index value of _batchOfAddresses
     * @return bool True if successful else false
     */
    function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyBeforeCrowdfund onlyOwner returns (bool success) {
        require(_batchOfAddresses.length == _amountOfTokens.length);
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
    function kill() external onlyOwner {
        var (amount,) = token.allocations(this);
        require(crowdfundFinalized == true && amount == 0);
        selfdestruct(owner);
    }

    /**
     * @dev Allows for users to send ETH to buy tokens
     */
    function () external payable {
        buyTokens(msg.sender);
    }
}
