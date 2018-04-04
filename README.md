# Smart Contract Requirements


## V1

### Ico creator

#### V1

Here is a list of all requirements needed for the token creator contract

- [X] ERC20 Compatible

- [X] Fixed total supply

- [X] Dynamic token allocation (less than or equal to 10)

- [X] Dynamic pricing rounds (less than or equal to 10)

- [X] Possibility to Burn unsold tokens or Move tokens to a known address (move allocation with 0 address as _to)

- [X] Possibility to schedule and reschedule your crowdfund.

- [X] Dynamic Vesting period

- [X] Presale seeding function


##### User stories

- A user can create a token contract to their spec (Name, Symbol, Total Supply) and it needs to be ERC20 compatible

- A user can setup multiple token allocations sending it to multiple addresses. Every token allocation is a percentage of the total supply. The sum of all allocations is the total supply

- A user is able to hold a presale off platform and send the tokens to a batch of addresses

- A user is able to setup multiple pricing rounds. All of these pricing rounds have both a `RATE` and an `EPOCH`

- Tokens should be locked for the duration of the crowdfund. Unlocked as soon as the crowdfund closes (or is done?)

- A user should be able to decide where the leftover tokens from the crowdfund are sent. Either they are going to an address or are burnt

- A user should be able to schedule his crowdfund and reschedule it (by doing a function call)

- A user should be able to create multiple allocations for his tokens, and every allocation should be able to vest for a variable amount of months.


##### Tools used:

- Solium:

`solium -d contracts/`
`solium -d contracts --fix`

- Solidity coverage

`./node_modules/.bin/solidity-coverage`

- Oyente https://github.com/melonproject/oyente

`docker run -i -t -v $(pwd)/contracts:/oyente/oyente/contracts luongnguyen/oyente`

`cd /oyente/oyente && python oyente.py -s contracts/Crowdfund.sol`

- Mythril

`pip3 install mythril`

Get the function signatures

```
 mkdir ~/.mythril
 cd ~/.mythril
 wget https://raw.githubusercontent.com/b-mueller/mythril/master/signatures.json
 ```


 `myth -x myContract.sol`

 - Solidity flatenner

 `solidity_flattener --output StandardTokenFlattened.sol StandardToken.sol`

 - Creating Go bindings

 `./createBindings`

