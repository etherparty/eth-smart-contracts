# Smart Contract Requirements


## V1

### Ico creator

#### V1

Here is a list of all requirements needed for the token creator contract

- [X] ERC20 Compatible

- [ ] Fixed total supply

- [ ] Dynamic token allocation

- [ ] Dynamic pricing rounds

- [ ] Possibility to Burn unsold tokens or Move tokens to a known address

- [ ] Possibility to start or schedule start your crowdfund.

- [ ] Dynamic Vesting period





##### Tools used:

- Solium:

`solium -d contracts/`
`solium -d contracts --fix`

- Solidity coverage

`./node_modules/.bin/solidity-coverage`

- Oyente

`docker run -i -t -v `pwd`/contracts:/oyente/contracts luongnguyen/oyente`
`cd /oyente/oyente && python oyente.py -s contracts/Crowdfund.sol`