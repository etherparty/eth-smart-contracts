pragma solidity ^0.4.15;

import "./library/SafeMath.sol";
import "./library/Ownable.sol";
import "./library/StandardToken.sol";

contract Token is StandardToken, Ownable {

    using SafeMath for uint;

/////////////////////// TOKEN INFORMATION ///////////////////////
    string public name = "NAME"; //{{.Name}} NAME CAN BE CHANGED 20 chars max
    string public symbol = "SYMBOL"; //{{.Symbol}} SYMBOL CAN BE CHANGED 3-5 symbols
    uint8 public decimals = 18; //{{.Decimal}} CAN BE CHANGED 0 --> 18

    // An allocation has a total balance and potentially a timelock (0 means no timelock)
    struct Allocation {
        uint256 balance;
        uint256 timeLock;
    }

    // Allocation keeps track of all the different allocations that the user created. Including crowdfund
    mapping (address => Allocation) public allocations;

/////////////////////// VARIABLE INITIALIZATION ///////////////////////

    // Total ICO supply
    uint256 public crowdfundSupply;
    // Crowdfund address
    address public crowdfundAddress;
    // Tokens transfers are locked until the crowdfund is closed -- SHOULD WE MAKE IT SO THE TOKENS ARE UNLOCKED WHEN THERE ARE NO MORE CROWDFUND TOKENS?
    bool public tokensLocked = true;


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
    function transfer(address _to, uint256 _amount) public onlyUnlocked returns (bool success) {
        return super.transfer(_to, _amount);
    }

    /**
     * @dev Transfer tokens from one address to another (needs allownace to be called first)
     * @param _from The address the tokens are transfered from
     * @param _to The address the tokens are being transfered to
     * @param _amount The amount of tokens transfered
     * @return bool True if successful else false
     */
    function transferFrom(address _from, address _to, uint256 _amount) public onlyUnlocked returns (bool success) {
        return super.transferFrom(_from, _to, _amount);

    }

/////////////////////// TOKEN FUNCTIONS ///////////////////////
    // We pass in only what we need (like length of crowdfund and the allocations)
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     * @param _totalSupply Total supply
     * @param _allocAddresses Allocation addresses
     * @param _allocBalances Allocation balances
     * @param _timelocks Array of _timelocks
     */
    function Token(
        address _owner,
        uint256 _totalSupply,
        address[] memory _allocAddresses,
        uint256[] memory _allocBalances,
        uint256[] memory _timelocks
        ) public {

        // Ensure that all three arrays have the same length and have a length cap of 10
        require(_allocAddresses.length == _allocBalances.length && _allocAddresses.length == _timelocks.length && _allocAddresses.length <= 10);
        owner = _owner;
        uint256 multiplier = 10**uint256(decimals);
        // Set the total supply (from inherited contract)
        totalSupply_ = _totalSupply.mul(multiplier);
        // Set the crowdfund address
        crowdfundAddress = msg.sender;
        // Go through every allocation, and add it in the allocations mapping
        uint256 totalTokens = 0;
        for (uint8 i = 0; i < _allocBalances.length; i++) {
            uint256 alloc = _allocBalances[i].mul(multiplier);
            // As we don't know the crowdfund contract address beforehand, the 0x0 address will be the one telling us the crowdfund allocation
            if (_allocAddresses[i] == address(0)) {
                // Msg.sender here is the Crowdfund contract, as it is the one creating this contract
                _allocAddresses[i] = crowdfundAddress;
                // Add to the crowdfundSupply variable
                crowdfundSupply = alloc;
                // The crowdfund allocation should not have a timelock
                _timelocks[i] = 0;
            }

            allocations[_allocAddresses[i]] = Allocation(alloc, _timelocks[i]);
            totalTokens = totalTokens.add(alloc);
        }
        // Ensure that the total supply matches all the allocations
        assert(totalTokens == totalSupply_);
    }

    /**
     * @dev Called by an allocation to send tokens to an address
     * @param _to The address the bought tokens are sent to
     * @param _amount The amount of tokens being sent
     * @return bool True if successful else false
     */
    function moveAllocation(address _to, uint256 _amount) public returns(bool success) {
        // Needs not be timelocked
        require(now > allocations[msg.sender].timeLock);
        // This function can be called by anyone, but as soon as the allocation goes below 0, it will revert
        allocations[msg.sender].balance = allocations[msg.sender].balance.sub(_amount);
        // Add to the msg.sender's balance
        balances[_to] = balances[_to].add(_amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Unlocks the tokens. Can only be called by the crowdfund contract
     * @return bool True if successful else false;
     */
    function unlockTokens() external returns (bool) {
        // This is a 1 way function, tokens can only be in an unlocked state
        require(msg.sender == crowdfundAddress);
        tokensLocked = false;
        return true;
    }
}
