# Oyente
```javascript
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     91.3%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      True
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:contracts/Crowdfund.sol:46:5: Warning: Integer Overflow.
    Rate[] public rates
contracts/Crowdfund.sol:244:30: Warning: Integer Overflow.
            if (daysPassed < rates[i].amountOfDays
Integer Overflow occurs if:
    rates = 115792089237316195423570985008687907853269984665640564039457584007913129639935
    withWhitelist = 0
    endsAt = 115792089237316195423570889227716603735216337268951367145133607836168237350911
    startsAt = 115792089237316195423570889227716603735216337268951367145133607836168237350911
contracts/Crowdfund.sol:290:5: Warning: Integer Overflow.
    function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    ^
Spanning multiple lines.
Integer Overflow occurs if:
    _beneficiaries = 115792089237316195423570985008687907853269984665640564039457584007913129639935
contracts/Crowdfund.sol:31:90: Warning: Integer Overflow.
    // Address to forward the tokens to at the end of the Crowdfund (can be 0x0 for burning to
Integer Overflow occurs if:
    _startDate = 1
    crowdfundLength = 115792089237316195423570985008687907853269984665640564039457584007913129639935
    isActivated = 0
contracts/Crowdfund.sol:261:39: Warning: Integer Overflow.
            if (!token.moveAllocation(_batchOfAddresses[i]
Integer Overflow occurs if:
    startsAt = 0
    _batchOfAddresses = 115792089237316195423570985008687907853269984665640564039457584007913129639899
contracts/Crowdfund.sol:215:5: Warning: Integer Overflow.
    function closeCrowdfund() external onlyAfterCrowdfund onlyOwner returns (bool success) {
    ^
Spanning multiple lines.
Integer Overflow occurs if:
    endsAt = 1
    crowdfundFinalized = 0
contracts/Crowdfund.sol:258:5: Warning: Integer Overflow.
    function deliverPresaleTokens(address[] _batchOfAddresses, uint[] _amountOfTokens) external onlyBeforeCrowdfund onlyOwner returns (bool success) {
    ^
Spanning multiple lines.
Integer Overflow occurs if:
    _batchOfAddresses = 115792089237316195423570985008687907853269984665640564039457584007913129639935
contracts/Crowdfund.sol:300:5: Warning: Integer Overflow.
    function removeManyFromWhitelist(address[] _beneficiaries) external onlyOwner {
    ^
Spanning multiple lines.
Integer Overflow occurs if:
    _beneficiaries = 115792089237316195423570985008687907853269984665640564039457584007913129639935
contracts/Crowdfund.sol:302:23: Warning: Integer Overflow.
            whitelist[_beneficiaries[i]
Integer Overflow occurs if:
    _beneficiaries = 115792089237316195423570985008687907853269984665640564039457584007913129639899
contracts/Crowdfund.sol:292:23: Warning: Integer Overflow.
            whitelist[_beneficiaries[i]
Integer Overflow occurs if:
    _beneficiaries = 115792089237316195423570985008687907853269984665640564039457584007913129639899
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/Token.sol:Token:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     82.7%
INFO:symExec:     Integer Underflow:                     True
INFO:symExec:     Integer Overflow:                      True
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:contracts/Token.sol:12:5: Warning: Integer Underflow.
    string public name = "NAME"
contracts/Token.sol:13:5: Warning: Integer Underflow.
    string public symbol = "SYMBOL"
INFO:symExec:contracts/Token.sol:24:5: Warning: Integer Overflow.
    mapping (address => Allocation) public allocations
contracts/Token.sol:141:23: Warning: Integer Overflow.
        require(now > allocations[msg.sender].timeLock
Integer Overflow occurs if:
    crowdFundStartTime = 115792089237316195423570985008687907853269984665640564039457584007913129639935
contracts/Token.sol:32:51: Warning: Integer Overflow.
    // Tokens transfers are locked until the crowdfund
Integer Overflow occurs if:
    allocations = 89660649888868366171417216235708288031085258661234677303951427843448891257349
    crowdFundStartTime = 95320360308092064085158862026869462789128858612754216248428463844421952977271
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/BasicToken.sol:BasicToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.5%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      True
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:contracts/library/BasicToken.sol:44:56: Warning: Integer Overflow.
  * @param _owner The address to query the the balance of.
  ^
Spanning multiple lines.
Integer Overflow occurs if:
    _value = 44369063854674067291029404066660873444229566625561754964912869797988903417852
    balances = 85653202831209899131921273706816539903532775246499202405936884825549521553152
    balances = 44369063854674067291029404066660873444229566625561754964912869797988903417852
    _to = 1461501637330902918203684832716283019655932542975
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/CanReclaimToken.sol:CanReclaimToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     97.5%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      False
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/NonZero.sol:NonZero:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      False
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/Ownable.sol:Ownable:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.5%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      False
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/SafeERC20.sol:SafeERC20:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      False
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/SafeMath.sol:SafeMath:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      False
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:root:contract contracts/library/StandardToken.sol:StandardToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.9%
INFO:symExec:     Integer Underflow:                     False
INFO:symExec:     Integer Overflow:                      True
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:contracts/library/StandardToken.sol:32:46: Warning: Integer Overflow.
    allowed[_from][msg.sender] = allowed[_from][ms
Integer Overflow occurs if:
    balances = 95515132405035013240498949941729301185179799140209929091396633094036584928231
    _value = 37717208912933073374861050775867160511051478474789766132129094234564326678807
    allowed = 37717208912933073374861050775867160511051478474789766132129094234564326678807
    balances = 37717208912933073374861050775867160511051478474789766132129094234564326678807
    _to = 1461501637330902918203684832716283019655932542975
INFO:symExec:   ====== Analysis Completed ======
```

# Code coverage

```javascript


  Contract: Crowdfund
    ✓ Init: The contract is initialized with the right variables (1190ms)
    ✓ Schedule and Reschedule crowdfund: It should schedule the crowdfund and not let me reschedule after the crowdfund is active (2067ms)
    ✓ Rates per epoch: It should return the right price when buying tokens (2184ms)
    ✓ Change Forward and Wallet Address: It should let only the owner to change those addresses (639ms)
    ✓ BuyTokens() and function (): It should let a buyer buy tokens (1680ms)
    ✓ BuyTokens(): It should not let a buyer buy tokens after there is no more crowdfund allocation (1080ms)
    ✓ closeCrowdfund(): It should let me close the crowdfund at the appropriate time (1075ms)
    ✓ closeCrowdfund(): It should let me burn tokens (1202ms)
    ✓ deliverPresaleTokens(): It should let me deliver the presale tokens at an appropriate time (1194ms)
    ✓ kill(): It should kill the contract under certain circumstances (1170ms)
    ✓ WHITELISTED BuyTokens() and function (): It should let a buyer buy tokens only if whitelisted (3014ms)
    ✓ changeCrowdfundStartTime, Should not let me call this function (397ms)

  Contract: Token
    ✓ Init: The contract is initialized with the right variables (725ms)
    ✓ Transfer: It tests the transfer function (1820ms)
    ✓ TransferFrom: It tests the transferFrom function (1950ms)
    ✓ MoveAllocation: It tests the moveAllocation function (1958ms)


  16 passing (24s)

----------------------|----------|----------|----------|----------|----------------|
File                  |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
----------------------|----------|----------|----------|----------|----------------|
 contracts/           |    93.81 |    77.59 |      100 |    94.39 |                |
  Crowdfund.sol       |    91.18 |       75 |      100 |    92.11 |... 222,227,262 |
  Token.sol           |      100 |    85.71 |      100 |      100 |                |
 contracts/library/   |    64.15 |    41.67 |    59.09 |    63.79 |                |
  BasicToken.sol      |      100 |       50 |      100 |      100 |                |
  CanReclaimToken.sol |        0 |      100 |        0 |        0 |          22,23 |
  ERC20.sol           |      100 |      100 |      100 |      100 |                |
  ERC20Basic.sol      |      100 |      100 |      100 |      100 |                |
  NonZero.sol         |    66.67 |       50 |    66.67 |    66.67 |          14,15 |
  Ownable.sol         |       40 |       50 |    66.67 |       50 |       37,38,39 |
  SafeERC20.sol       |        0 |        0 |        0 |        0 |       15,19,23 |
  SafeMath.sol        |    91.67 |     62.5 |      100 |    91.67 |             15 |
  StandardToken.sol   |    52.38 |     37.5 |       40 |    52.38 |... 92,94,96,97 |
----------------------|----------|----------|----------|----------|----------------|
All files             |    83.33 |    63.83 |    81.63 |    83.64 |                |
----------------------|----------|----------|----------|----------|----------------|

```

# Mythril

```
==== CALL with gas to dynamic address ====
Type: Warning
Contract: Crowdfund
Function name: _function_0x17ffc320
PC address: 7915
The function _function_0x17ffc320 contains a function call to an address provided as a function argument. The available gas is forwarded to the called contract. Make sure that the logic of the calling contract is not adversely affected if the called contract misbehaves (e.g. reentrancy).
--------------------

==== CALL with gas to dynamic address ====
Type: Warning
Contract: Crowdfund
Function name: _function_0x17ffc320
PC address: 2912
The function _function_0x17ffc320 contains a function call to an address provided as a function argument. The available gas is forwarded to the called contract. Make sure that the logic of the calling contract is not adversely affected if the called contract misbehaves (e.g. reentrancy).
--------------------



```

*Errors due to ReclaimToken, which uses SafeTransfer which is fine*