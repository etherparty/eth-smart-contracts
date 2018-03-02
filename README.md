# Smart Contract Requirements


## V1

### Ico creator

#### V1

Here is a list of all requirements needed for the token creator contract

- [X] ERC20 Compatible

- [X] Fixed total supply

- [X] Dynamic token allocation

- [X] Dynamic pricing rounds

- [X] Possibility to Burn unsold tokens or Move tokens to a known address

- [X] Possibility to start or schedule start your crowdfund.

- [X] Dynamic Vesting period

- [X] Presale seeding function


##### User stories

- A user can create a token contract to their spec (Name, Symbol, Total Supply) and it needs to be ERC20 compatible

- A user can setup multiple token allocations sending it to multiple addresses. Every token allocation is a percentage of the total supply. The sum of all allocations is the total supply

- A user is able to hold a presale off platform and send the tokens to a batch of addresses

- A user is able to setup multiple pricing rounds. All of these pricing rounds have both a `RATE` and an `EPOCH`

- Tokens should be locked for the duration of the crowdfund. Unlocked as soon as the crowdfund closes (or is done?)

- A user should be able to decide where the leftover tokens from the crowdfund are sent. Either they are going to an address or are burnt

- A user should be able to schedule his crowdfund (hard coded) OR decided to start it when he wants (by doing a function call)

- A user should be able to create multiple allocations for his tokens, and every allocation should be able to vest for a variable amount of months.


##### Tools used:

- Solium:

`solium -d contracts/`
`solium -d contracts --fix`

- Solidity coverage

`./node_modules/.bin/solidity-coverage`

- Oyente https://github.com/melonproject/oyente

`docker run -i -t -v `pwd`/contracts:/oyente/contracts luongnguyen/oyente`
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

