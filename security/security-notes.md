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

## Oracle Manipulation Attacks

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/23.png?raw=true)

Imagine a scenario, where an application is using a DEX/AMM reserves as the source of truth for the prices.

But this is a very very bad approach, because "Flash Loans" can easily manipulate the price of tokens for a transaction and can buy stuff for unreal prices.

Hence we must never use a DEX as an oracle.
A famous example of Oracle manipulation using flash loans is the 2021 attack of Cream Finance.<br>
https://rekt.news/cream-rekt-2/

## Reentrancy Attack

This is very simple, whenever you are making an external call make sure you are updating the effects before interaction with external calls. Or else the fallbacks of attack contracts can drain the vulnerable contracts.

Prevention:

1. Ensure all state changes happen before calling external contracts
2. Use function modifiers that prevent re-entrancy

## Hiding Malicious Code with External Contract

In Solidity any address can be casted into specific contract, the casting does not verify whether the address being casted is actually the contrac we want to cast into or not, so attackers can use this to hide malicious code.

Essentially, when looked at the code, the user might think that he is interacting to a specific contract, but actually he is interacting with a contract that can have any code.

## Relying on ExtCode size

In below contract protected() can be called with a contract as well.

Its because, the extcodesize(address) is zero for a contract while its still being constructed.

And hence, I can call the protected method from a contract within the constructor and it would pass.

```sol
contract Target {
    function isContract(address account) public view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    bool public pwned = false;

    function protected() external {
        require(!isContract(msg.sender), "no contract allowed");
        pwned = true;
    }
}
```

## Cross-chain Replay Attacks

For EVM-compatible rollups, it is also worth noting that when transactions are sent from L1 to L2, the address of the sender of the transaction on L2 will be set to the address of the sender of the transaction on L1.
However, the address of the sender of a transaction on L2 will be different if the transaction was triggered by a smart contract on L1.

It is possible to have smart contracts on both the L1 and L2 with the same address but different bytecode (different implementations) due to the behavior of the CREATE opcode.

If the sender of the L2 transaction is an L1 smart contract with the same address as a contract on the L2, the transaction can be replayed on the L2 but using the L2 contract implementation. To mitigate this, some contracts on rollups are aliased to avoid them being called maliciously.

Prevention:

To prevent cross-chain replay attacks, use a chain-specific signature scheme such as EIP-155, which includes the chain ID in the signed message. The signature should also be verified using the chain ID. This will prevent transactions signed on one chain from being replayed on another chain.
