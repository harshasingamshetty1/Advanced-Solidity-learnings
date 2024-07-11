## MEV Attacks (Maximum extractable Value)

resources:<br>
https://github.com/Cyfrin/sc-exploits-minimized<br>
https://solidity-by-example.org/hacks/re-entrancy/

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/20.png?raw=true)

Basics first, whenever a txn is sent by a user throough an RPC url, it goes to a corresponding node (validator).

So, the validator, takes the txn and puts it in the "Transaction Mempool".
And it is visible to all the nodes, so therefore any node can pick any transaction (usually based on priority gas fee) and validate and put it on blockchain.

This means that, everyone has access to the potential future of the blockchain, bcoz of the mempool.

And the MEV bots always scan the mempool and can easily perform sandwich attacks if the slippage tolerance is high.

## Flash Loans

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/21.png?raw=true)

Simply put, flash loans are loans that are valid for a single transaction.
i.e You can take a loan and do any thing (like arbitrage etc) and finally return the entire amount + fees, or else simply the contract will revert everything and hence all the arbitrage will be lost as well.

First of all, how does the contract have such huge funds ?
Simple, Liquidity providers.

So, the Liquidity providers deposit their funds into the contracts and hence, they earn rewards based off of the protocol fee, which is paid by the users who use the Flash loans

### Simple Arbitrage with Flash loans

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/22.png?raw=true)

So essentially, we can say that, in traditional finance only whales used to have the opprtunity to do arbitrage trades, but with Flash loans in DEFI the playing field is levelled for everyone, and anyone can be rich for a single transaction.

Now lets discuss all types of known attacks:
