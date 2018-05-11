pragma solidity 0.4.21;

import "./library/SafeMath.sol";
import "./library/Ownable.sol";
import "./library/StandardToken.sol";

contract Token is StandardToken, Ownable {

    using SafeMath for uint;

/////////////////////// TOKEN INFORMATION ///////////////////////
    string public name = "NAME";
    string public symbol = "SYMBOL";
    uint8 public decimals = 18;


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
    // Tokens transfers are locked until the crowdfund is closed
    bool public tokensLocked = true;
    // Crowdfund start Date. Needed for token vesting schedule as a user can reschedule the crowdfund
    uint256 public crowdFundStartTime;


/////////////////////// Modifiers ///////////////////////
    // Modifier that checks if the tokens are unlocked
    modifier onlyUnlocked() {
        require(tokensLocked == false);
        _;
    }

    // Modifier that ensures that the call is coming from the Crowdfund
    modifier onlyCrowdfund() {
        require(msg.sender == crowdfundAddress);
        _;
    }

/////////////////////// ERC20 FUNCTIONS ///////////////////////

    /**
     * @dev Transfer tokens to an address
     * @param _to The address the tokens are transfered to
     * @param _amount The amount of tokens transfered
     * @return bool True if successful else false
     *
     *
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
    /**
     * @dev Constructor
     * @param _owner The address of the contract owner
     * @param _totalSupply Total supply
     * @param _allocAddresses Allocation addresses
     * @param _allocBalances Allocation balances
     * @param _timelocks Array of _timelocks (in amount of seconds)
     */
    function Token(
        address _owner,
        uint256 _totalSupply,
        address[] memory _allocAddresses,
        uint256[] memory _allocBalances,
        uint256[] memory _timelocks
        ) public {

        // Ensure that all three arrays have the same length and have a length cap of less than or equal to 10
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
     * @dev Called by the crowdfund contract to reschedule vesting periods
     * @param _crowdFundStartTime Timestamp of crowdfund start time
     * @return bool True if successful
     */
    function changeCrowdfundStartTime(uint256 _crowdFundStartTime) onlyCrowdfund external returns(bool) {
        crowdFundStartTime = _crowdFundStartTime;
        return true;
    }

    /**
     * @dev Called by an allocation to send tokens to an address
     * @param _to The address the bought tokens are sent to
     * @param _amount The amount of tokens being sent
     * @return bool True if successful else false
     */
    function moveAllocation(address _to, uint256 _amount) public returns(bool) {
        // Crowdfund sate needs to be initialized
        require(crowdFundStartTime > 0);
        // Vesting for this specific address needs to be done or we let the crowdfund address get his allocation
        require(now > allocations[msg.sender].timeLock.add(crowdFundStartTime) || msg.sender == crowdfundAddress);
        // This function can be called by anyone, but as soon as the allocation goes below 0, it will revert
        allocations[msg.sender].balance = allocations[msg.sender].balance.sub(_amount);
        // Add to the msg.sender's balance
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(0x0, _to, _amount);
        return true;
    }

    /**
     * @dev Unlocks the tokens. Can only be called by the crowdfund contract
     * @return bool True if successful else false;
     */
    function unlockTokens() external onlyCrowdfund returns (bool) {
        // This is a 1 way function, tokens can only be moved from a locked state to unlocked, and not vice versa
        tokensLocked = false;
        return true;
    }
}
