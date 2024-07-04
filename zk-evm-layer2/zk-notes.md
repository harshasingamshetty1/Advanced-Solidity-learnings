# Layer 2

[https://l2beat.com/scaling/summary]
<br>Simply put, layer 2 just computes txns and batch them together to send it to the Ethereum(L1).
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

And now, imagine there are no broadcasting partners as well. Which means you cannot know what happened in the match, and you must just trust whoever have watched the match.

You wont even know if the umpires, were fair to your fav team.

That's it, in this case the Broadcasting channels serves as the Data Availability Layer.

Because, not everyone can become an ETH validator, just to know if everything is happeing properly on Blockchain.

Important:

1. DA is not gurantee data validation, ie it just stores data and its job of Blockchains to verify it
2. DA is not for Data Storage
3. DA does not gurantee data permanence

So essentially every Blockchain has its own DA layer, but currently Celstia, Avail are offering DA as a service so that, other blockchains can just use, because it becomes cheaper this way.

## Rollups

2 Important things that Zk rollups do:

1. Post the transaction data of the L2 onto Ethereum
2. Post the Zk proofs backing the posted txn data

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/13.png?raw=true)

### Blobs [EIP 4844]

Recent advancements for rollup tech involves in the Blobs.

At the heart of the blobs token mechanism is "blob transactions." These transactions are integral to EIP-4844 and introduce large data packets (the blobs) that can be included in Ethereum blocks. **Unlike typical Ethereum transactions, which are processed and stored permanently by the Ethereum Virtual Machine (EVM)**, blobs provide a more scalable and cost-effective way to handle large amounts of data.

The EVM doesn't directly process blobs, but thanks to KZG cryptographic commitments, they can still be included in the blockchain. In other words, they can temporarily store data, which is especially advantageous for L2 rollup solutions requiring proofs to be submitted to the Ethereum mainnet for verification.

Using blobs allows these solutions to significantly decrease the amount of data they must permanently store, resulting in lower gas fees.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/14.png?raw=true)

## Validiums

The main difference of validuims are,

1. They do not post the Txn data on to the L1 unlike rollups
2. But they do post the proofs in this case zk proofs to the L1s

They store the txn data in DAs like Eigen, Avail or Celestia.
Becoz, storing the txn data onto L1 can be expensive.

Drawback: The major drawback is that, we cannot regenerate the enitre state of a Validium just from the base L1, which is possible in rollups as we post the txn data as well.

Exmples of validiums include: ImmutableX, Myria, Astar zkEVM,

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/15.png?raw=true)

## L2 txn lifecycle

1. A txn on L2 is first included in a Block
2. A block can have multiple txns
3. A block is involved in a batch.
4. Now the batch of L2 txns are aggregated by the aggregator and then sent to the Rollup contract of L1 and `squenceBatches` function is executed.
5. Similarly, the L2 txns batch verification is posted on to L1 and the `verifyBatchesTrustedAggregator` method is executed on L1

So with this mechanism, Rollups post both the txn data as well as verification data on to the L1 layer.

## Eigen Layer

Before Eigen, if a protocol wants to have high decen and security as ETH. Its not possible if the service you are trying to provide is not a smart contract, then you cant utilise the ETh's security.

The usual solution would be to give higher rewards to attract the ETH validators to come and secure your network

Problems:

1. Its not feasible
2. Bcoz, Stakers wouldnt come to you even if you give high rewards bcoz your token cannot be as stable as ETH.

So the solution,
Simply put, Eigen layer is reutilising the already staked eth of validators in the Ethereum ecosystem, to be able to use for other services as well, so Eth level of decentralisation and security is available for other services as well.

So there are

1. Stakers
2. Operators
3. Developers

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/16.png?raw=true)
![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/17.png?raw=true)
![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/18.png?raw=true)

### The First AVS (Actively Validated Service): Eigen DA

Eigen DA is secured by the ETH validators, who can opt in to secure the Eigen layer, without having to remove any current stakings etc.

With this, the validators receive additional rewards apart from those they already receive from ETH staking as a validator.

In return it helps Eigen Layer to provide super security and decnzn for any AVS that opt to use Eigen Layer

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/19.png?raw=true)

### Eigen Layer Risks

There are obvious risks invloved.

1. The staker is trusting the operator they are delegating to. If the operator misbehaves, the staker could miss out on potential fee payments or even lose their entire stake.

2. The operator is relying on the AVS developer to accurately code the client software and the onchain slashing condition. If there are bugs in the AVS softwares, at best, the operator might miss potential fee payments. At worst, the operator could be slashed for all their stakes.

But luckily there is a Veto committee, which can do the reverse slashing, in cases where no one has misbehaved but the tokens are slashed due to some misunderstanding or bugs etc.
