# Understanding EVM

EVM has a world state which is the state of all the accounts both EOA, and Contracts.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/1.png?raw=true)

Each txn modifies the world state, and result into a new state.

The entire blockchain can be visualized into a huge trie structure, where each node is either a EOA or a contract.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/2.png?raw=true)

Each contract in return again is a Merkle Patricia trie, where all the storage values are stored.

So, for every txn, atleast one node's state changes and hence changing the entire state root of Ethereum

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/3.png?raw=true)
