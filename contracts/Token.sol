pragma solidity ^0.4.15;

import "zeppelin-solidity/contracts/math/SafeMath.sol";
import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract Token is StandardToken, Ownable {

    using SafeMath for uint;

// Maybe declare all the vars we will be using on the top level here along with their visibility


/////////////////////// TOKEN INFORMATION ///////////////////////
    string public constant name = "NAME"; //{{.Name}} NAME CAN BE CHANGED 20 chars max?
    string public constant symbol = "SYMBOL"; //{{.Symbol}} SYMBOL CAN BE CHANGED 3-5 symbols
    uint256 private constant totSup = 100000; // {.TotalSupply} can go up to ??
    uint8 public decimals = 18; //{{.Decimal}} CAN BE CHANGED 0 --> 18
    uint256 public crowdfundLength = 10000; // {{.CrowdfundLength}}

    struct allocation {
        address owner;
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

    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     */
    function Token(address _owner) public {
        totalSupply_ = totSup; // For the totalSupply() function upstream
        owner = _owner;
    /*
        type Allocation struct { Address: addr, Balance: balance, Timelock: timelock}
        .... get the []Allocation struct
        for _, allocation := range allocations {
        `allocations[allocation.Address] = allocation(allocation.Address, allocation.Balance, allocation.Timelock);
        crowdfundSupply -= allocation.Balance`
        }
        crowdfundSupply = totalSupply_;
        assert(crowdfundSupply == {{.CrowdfundSupply}});

        We can do assertions like this on the constructor to double check all
    */
        allocations[msg.sender] = allocation(msg.sender, crowdfundSupply, 0); // Crowdfund is an allocation like any other (msg.sender is the crowdfund contract)
        // One side effect is that we cannot see the contracts "balance" directly on Etherscan

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
