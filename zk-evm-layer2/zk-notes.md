# Layer 2

Simply put, layer 2 just computes txns and batch them together to send it to the Ethereum(L1).
![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/11.png?raw=true)

## L2 Architecture

1. Whatever is present in the Pending txn pool, is either executed or discarded by the sequencer based on the validity.
2. Now, the data is passed to the Roll up Smart Contract on the L1 Blockchain
3. Now, before actually believing the data it received, the data is first verified if its valid or not through the verifier.
4. The verification can happen in any way like ZK or Optimistic etc.
5. So basically the verification is nothing but, whether the data received by the Rollup contract, correctly represnts the entire present world state of L2 or not.
6. Once that is verfied, the verification is completd

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/12.png?raw=true)

## What is Data Availability ?

Lets explore with an Analogy.
Imagine the Cricket World cup Final is gonna happen tomorrow. And you are too broke to buy those costly tickets.

And now, imagine even there are no broadcasting partners as well. Which means you cannot know what happened in the match, and you must just trust whoever have watched the match.

You wont even know if the umpires, were fair to your fav team.

That's it, in this case the Broadcasting channels Served as the Data Availability Layer.

Because, not everyone can become an ETH validator, just to know if everything is happeing properly on Blockchain.

Important:

1. DA is not gurantee data validation, ie it just stores data and its job of Blockchains to verify it
2. DA is not for Data Storage
3. DA does not gurantee data permanence

So essentially every Blockchain has its own DA layer, but currently Celstia, Avail are offering DA as a service so that, other blockchains can just use, because it becomes cheaper this way.
