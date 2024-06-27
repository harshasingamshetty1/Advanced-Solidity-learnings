# Understanding EVM

EVM has a world state which is the state of all the accounts both EOA, and Contracts.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/1.png?raw=true)

Each txn modifies the world state, and result into a new state.

The entire blockchain can be visualized into a huge trie structure, where each node is either a EOA or a contract.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/2.png?raw=true)

Each contract in return again is a Merkle Patricia trie, where all the storage values are stored.

So, for every txn, atleast one node's state changes and hence changing the entire state root of Ethereum

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/3.png?raw=true)

The imp thing or a blockchain is that, given an initial state, and a txn data, the next state generated to be exactly same for ever node, irrespective of what OS, hardware the node is using etc.

So, wkt for these purposes Virtual machines are perfect

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/4.png?raw=true)

## Architecture

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/5.png?raw=true)

The machine state is where the txn will be processed.
And the storage of contracts is fetched from the World state.

EVM can be understood as analogous to a CPU.
But rather than a registers based architecture, it has a stack based architecture

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/6.png?raw=true)

Understand that, EVM is like a single threaded execution.[Not considering the L2s]

Before each txn, the code of contract being called is loaded, program counter is set to 0, the state storage of the contract is loaded from world state, the memory is all set to 0 and all block and env vars are set.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/7.png?raw=true)

If gas limit is hit while execn, all the state changes are reverted, only the senders nonce is incremented, and their ETH balance is cut, for wasting time of EVM and so that no one can abuse the system

## Gas cost vs Gas Price

Gas price is dependent on the network conditions i.e when the netowrk is congested, you will have to pay more eth per gas.

But the gas cost remains constant always.

We have a gas limit per block, which inderctly refers to max gas per txn as well, and hence EVM is not exactly a turing complete, but a quasi turing complete due to this limitaion

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/8.png?raw=true)

## Opcodes

EVM has all the basic math opcodes, which all the assembly level languages have.

But here are some opcode, which are specific to blockchain and ethereum environment.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/9.png?raw=true)

EVM has just the access to the current world state. Nothing other than that. No external APIs nothing!

This is because that the main objective of this sand boxed virtual machines that is an EVM is that, given an initial state, and a txn data, the next state generated to be exactly same for ever node, irrespective of what OS, hardware the node is using etc.

And so, we cannot have external APIs, which could hinder this feature and each node could have different world states of Ethereum and hence can cause many different forks of the blockchain

And hence the need of Oracle providers like Chainlink.

### Contract call within a txn

A Smart contract can call another contract, and each call to another contract create a brand new EVM instance of the EVM. Each call passes the sandbox world state to the next EVM.

And ofcourse, if the gas runs out all these world state changes are discarded.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/10.png?raw=true)
