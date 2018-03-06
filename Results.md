# Oyente
```
INFO:root:contract contracts/merged/Test.sol:BasicToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.5%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:CanReclaimToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     97.6%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:Crowdfund:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     89.4%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:NonZero:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:Ownable:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.5%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:SafeERC20:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:SafeMath:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     100.0%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:StandardToken:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     99.9%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:root:contract contracts/merged/Test.sol:Token:
INFO:symExec:   ============ Results ===========
INFO:symExec:     EVM Code Coverage:                     98.3%
INFO:symExec:     Parity Multisig Bug 2:                 False
INFO:symExec:     Callstack Depth Attack Vulnerability:  False
INFO:symExec:     Transaction-Ordering Dependence (TOD): False
INFO:symExec:     Timestamp Dependency:                  False
INFO:symExec:     Re-Entrancy Vulnerability:             False
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
INFO:symExec:   ====== Analysis Completed ======
```

# Code coverage

```javascript
  Contract: Crowdfund
    ✓ Init: The contract is initialized with the right variables (1088ms)
    ✓ Schedule and Reschedule crowdfund: It should schedule the crowdfund and not let me reschedule after the crowdfund is active (1565ms)
    ✓ Rates per epoch: It should return the right price when buying tokens (1844ms)
    ✓ Change Forward and Wallet Address: It should let only the owner to change those addresses (518ms)
    ✓ BuyTokens() and function (): It should let a buyer buy tokens (1464ms)
    ✓ BuyTokens(): It should not let a buyer buy tokens after there is no more crowdfund allocation (935ms)
    ✓ closeCrowdfund(): It should let me close the crowdfund at the appropriate time (997ms)
    ✓ closeCrowdfund(): It should let me burn tokens (1023ms)
    ✓ deliverPresaleTokens(): It should let me deliver the presale tokens at an appropriate time (1073ms)
    ✓ kill(): It should kill the contract under certain circumstances (923ms)

  Contract: Token
    ✓ Init: The contract is initialized with the right variables (570ms)
    ✓ Transfer: It tests the transfer function (1037ms)
    ✓ TransferFrom: It tests the transferFrom function (1030ms)
    ✓ MoveAllocation: It tests the moveAllocation function (1361ms)


  14 passing (16s)

----------------------|----------|----------|----------|----------|----------------|
File                  |  % Stmts | % Branch |  % Funcs |  % Lines |Uncovered Lines |
----------------------|----------|----------|----------|----------|----------------|
 contracts/           |    95.12 |       75 |      100 |    95.45 |                |
  Crowdfund.sol       |    92.86 |       75 |      100 |    93.44 |181,196,201,236 |
  Token.sol           |      100 |       75 |      100 |      100 |                |
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
All files             |    82.96 |    60.71 |    78.57 |    82.88 |                |
----------------------|----------|----------|----------|----------|----------------|
```

# Mythril

```
==== CALL with gas to dynamic address ====
Type: Warning
Contract: Crowdfund
Function name: _function_0x17ffc320
PC address: 6245
The function _function_0x17ffc320 contains a function call to an address provided as a function argument. The available gas is forwarded to the called contract. Make sure that the logic of the calling contract is not adversely affected if the called contract misbehaves (e.g. reentrancy).
--------------------

==== CALL with gas to dynamic address ====
Type: Warning
Contract: Crowdfund
Function name: _function_0x17ffc320
PC address: 2476
The function _function_0x17ffc320 contains a function call to an address provided as a function argument. The available gas is forwarded to the called contract. Make sure that the logic of the calling contract is not adversely affected if the called contract misbehaves (e.g. reentrancy).
--------------------
```

*Errors due to ReclaimToken, which uses SafeTransfer which is fine*