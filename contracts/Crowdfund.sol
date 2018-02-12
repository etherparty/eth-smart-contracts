pragma solidity ^0.4.15;

import "./zeppelin-solidity/SafeMath.sol";
import "./zeppelin-solidity/CanReclaimToken.sol";
import "./helpers/NonZero.sol";
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
    bool private isReadyToActivate = false;
    // Flag keeping track of crowdsale status. Ensures functions can only be called once
    bool public crowdfundFinalized = false;


    // Our own vars
    // Address of secure wallet to send crowdfund contributions to
    address public wallet; // {{.WalletAddress}}

    address public forwardTokensTo; // {{.forwardTokensTo}}

    uint256 public crowdfundLength; // {{.CrowdfundLength}}

    uint256 public totalDays;


    struct rate {
        uint256 price;
        uint8 amountOfDays;
    }

    // here we are saying that the rate is 1ETH=1000 Tokens for 3 days, then 750 from days 3 to day 5 etc
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
    modifier notBeforeCrowdfundEnds() {
        require(now >= endsAt);
        _;
    }

    modifier onlyBeforeCrowdfund() {
        require(now <= startsAt);
        _;
    }

    modifier nonZeroAddress(address _address) {
        require(_address != address(0));
        _;
    }

/////////////////////// CROWDFUND FUNCTIONS ///////////////////////
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     */
    function Crowdfund(
        address _owner,
        uint8[] memory amountOfDays,
        uint256[] memory prices,
        address _wallet,
        address _forwardTokensTo,
        bool manualActivation,
        uint256 _activationDate,
        uint256 _crowdfundLength,
        address[] memory _allocAddresses,
        uint256[] memory _allocBalances,
        uint256[] memory _timelocks
        ) public {


        assert(amountOfDays.length == prices.length && prices.length < 10);
        for (uint8 i = 0; i < amountOfDays.length; i++) {
            rates.push(rate(prices[i], amountOfDays[i]));
        }

        if (!manualActivation) {
            // Either we start the crowdfund now (or at a set time later), or call the startCrowdfund contract manually in the future.
            startsAt = _activationDate;
            if (startsAt == 0) {
                startsAt = now;
            }
            endsAt = startsAt + _crowdfundLength;
            isReadyToActivate = true;
            assert(startsAt >= now && endsAt > startsAt );
        }
        // Change the owner to the owner address.
        owner = _owner;
        token = new Token(owner, _crowdfundLength, _allocAddresses, _allocBalances, _timelocks); // Create new Token

        wallet = _wallet;
        forwardTokensTo = _forwardTokensTo;
        crowdfundLength = _crowdfundLength;
        totalDays = crowdfundLength / 1 days;
    }

    /**
     * @dev Called by the owner or the contract at the start of the crowdfund
     */
    function startCrowdfund() public returns(bool) {
        require(msg.sender == owner);
        require(isReadyToActivate == false);
        require(endsAt == 0);
        startsAt = now;
        // Sending in 0 will make it so you start the crowdfund now.
        endsAt = startsAt + crowdfundLength;
        isReadyToActivate = true;
        assert(startsAt >= now && endsAt > startsAt);
        return true;
    }

    /**
     * @dev Change the main contribution wallet
     * @param _wallet The new contribution wallet address
     */
    function changeWalletAddress(address _wallet) onlyOwner nonZeroAddress(_wallet) public {
        wallet = _wallet;
    }

    /**
     * @dev Change the main contribution wallet
     * @param _forwardTokensTo The new contribution wallet address
     */
    function changeForwardAddress(address _forwardTokensTo) onlyOwner nonZeroAddress(_forwardTokensTo) public {
        forwardTokensTo = _forwardTokensTo;
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
    function () payable external {
        buyTokens(msg.sender);
    }
}
