pragma solidity ^0.4.13;

library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

contract NonZero {

// Functions with this modifier fail if he 
    modifier nonZeroAddress(address _to) {
        require(_to != 0x0);
        _;
    }

    modifier nonZeroAmount(uint _amount) {
        require(_amount > 0);
        _;
    }

    modifier nonZeroValue() {
        require(msg.value > 0);
        _;
    }

}

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract Token is StandardToken, Ownable {

    using SafeMath for uint;

// Maybe declare all the vars we will be using on the top level here along with their visibility


/////////////////////// TOKEN INFORMATION ///////////////////////
    string public name = "NAME"; //{{.Name}} NAME CAN BE CHANGED 20 chars max?
    string public symbol = "SYMBOL"; //{{.Symbol}} SYMBOL CAN BE CHANGED 3-5 symbols
    uint8 public decimals = 18; //{{.Decimal}} CAN BE CHANGED 0 --> 18
    uint256 private crowdfundLength; // {{.CrowdfundLength}}

    struct allocation {
        uint256 balance;
        uint256 timeLock;
    }

    // Mapping to keep allocations
    mapping (address => allocation) public allocations;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////

    // Total ICO supply
    uint256 public crowdfundSupply;
    // Crowdfund address
    address public crowdfundAddress;
    // Tokens transfers are locked until the crowdfund is closed
    bool tokensLocked = true;


/////////////////////// Modifiers ///////////////////////
    modifier onlyUnlocked() {
        require(tokensLocked == false);
        _;
    }
/////////////////////// ERC20 FUNCTIONS ///////////////////////

    /**
     * @dev Transfer tokens to an address
     * @param _to The address the tokens are transfered to
     * @param _amount The amount of tokens transfered
     * @return bool True if successful else false
     */
    function transfer(address _to, uint256 _amount) onlyUnlocked public returns (bool success) {
        return super.transfer(_to, _amount);
    }

    /**
     * @dev Transfer tokens from one address to another (needs allownace to be called first)
     * @param _from The address the tokens are transfered from
     * @param _to The address the tokens are being transfered to
     * @param _amount The amount of tokens transfered
     * @return bool True if successful else false
     */
    function transferFrom(address _from, address _to, uint256 _amount) onlyUnlocked public returns (bool success) {
        return super.transferFrom(_from, _to, _amount);

    }

/////////////////////// TOKEN FUNCTIONS ///////////////////////
    // We pass in only what we need (like length of crowdfund and the allocations)
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     */
    function Token(
        address _owner,
        uint256 _crowdfundLength,
        address[] memory allocAddresses,
        uint256[] memory allocBalances,
        uint256[] memory timelocks) public {

        require(allocAddresses.length == allocBalances.length && allocAddresses.length == timelocks.length);
        owner = _owner;
        crowdfundLength = _crowdfundLength;

        for (uint8 i = 0; i < allocBalances.length; i++) {
            if(allocAddresses[i] == address(0)) {
                crowdfundSupply = allocBalances[i];
                allocAddresses[i] = msg.sender;
            }
            allocations[allocAddresses[i]] = allocation(allocBalances[i], timelocks[i]);
        }

        allocations[msg.sender] = allocation(crowdfundSupply, 0); // Crowdfund is an allocation like any other (msg.sender is the crowdfund contract)

        crowdfundAddress = msg.sender;
    }

    /**
     * @dev Called by an allocation to send tokens to an address
     * @param _to The address the bought tokens are sent to
     * @param _amount The amount of tokens being sent
     * @return bool True if successful else false
     */
    function moveAllocation(address _to, uint256 _amount) public returns(bool success) {
        require(allocations[msg.sender].timeLock < now);
        allocations[msg.sender].balance = allocations[msg.sender].balance.sub(_amount); // will throw if goes less than 0
        balances[_to] = balances[_to].add(_amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Unlocks the tokens. Can only be called by the crowdfund contract
     * @return bool True if successful else false;
     */
    function unlockTokens() external returns (bool) {
        require(msg.sender == crowdfundAddress);
        tokensLocked = false;
        return true;
    }
}

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

