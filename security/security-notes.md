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

## msg.value attack (mishandling ETH)

Case study:
https://samczsun.com/two-rights-might-make-a-wrong/

The major point was, there was a batch transaction which trasnfers eth, but the msg.value of single txn could be used for every other txn in the batch.

In the case of sushi swap,it was a huuuuge issue, it could have led to almost $350 Mil in loss,

Key Takeaways:

First, using msg.value in complex systems is hard. It’s a global variable that you can’t change and persists across delegate calls.

If you use msg.value to check that payment was received, you absolutely cannot place that logic in a loop. As a codebase grows in complexity, it’s easy to lose track of where that happens and accidentally loop something in the wrong place.

Although wrapping and unwrapping of ETH is annoying and introduces extra steps, the unified interface between WETH and other ERC20 tokens might be well worth the cost if it means avoiding something like this.

## Denial of Service (DoS) Attacks

Simply put, DoS attacks are basically trying to make the contract crash, or else it will not be able to process any further transactions.

It can happen in cases like, lets say you have a state variable in a contract and are iterating over it and as the array of size keeps on increasing, the block gas limit will be exhausted and the contract will not be able to perform that function anymore.

So always keep in mind of the Block gas limit, when you are iterating over any large array or something.

Resolution: We can just use batches of data for each processing

And DoS is not just limited to when the gas limit is exhausted.
Its just when, somehow the functinality of the contract is not able to perform its task.

Imagine a situation, where you have a code like this:
`(bool success, ) = target.call{value: amount}("");`

And your function checks whether the success is true or not, and if it is not, it will revert the transaction.

In some situtaions that might be helpful. But imagine if this is something happeining in a scenario of liquidation of a loan.

In these cases, even though the txn was not succesful, we must not revert, or else some malicious contract, can just have a revert statement in its fallback or even simple to not have any fallback or receive at all.

In these cases, it will be impossible to liquidate those malicious contracts.

# Additional Notes:

## Precompiles

Precompiles in Ethereum (not specifically in Solidity, but used with Solidity contracts) are special contracts with predefined addresses that implement frequently used or computationally intensive operations. They are built into the Ethereum protocol for efficiency and are executed directly by the Ethereum Virtual Machine (EVM) rather than as regular smart contract code.

Key points about precompiles:

1. Efficiency: They're optimized implementations of complex operations.
2. Gas savings: Generally cheaper to use than implementing the same functionality in Solidity, also much faster than calling a regular smart contract.
3. Fixed addresses: Each precompile has a specific address
4. Standardization: Provides a standard, verified implementation of complex operations.

#### Examples

a) Original precompiles (addresses 0x1 to 0x4):

```bash
ECRECOVER (0x1)
SHA256 (0x2)
RIPEMD160 (0x3)
IDENTITY (0x4)
```

b) Byzantium fork additions (addresses 0x5 to 0x8):

```bash
MODEXP (0x5)
ECADD (0x6)
ECMUL (0x7)
ECPAIRING (0x8)
```

c) Istanbul fork addition:

BLAKE2F (0x9)

d) Berlin fork additions:

```bash BLS12_G1ADD (0xA)
BLS12_G1MUL (0xB)
BLS12_G1MULTIEXP (0xC)
BLS12_G2ADD (0xD)
BLS12_G2MUL (0xE)
BLS12_G2MULTIEXP (0xF)
BLS12_PAIRING (0x10)
BLS12_MAP_FP_TO_G1 (0x11)
BLS12_MAP_FP2_TO_G2 (0x12)
```

## Signatures

How signing works:

1. Take private key and message (data,function selector, params)
2. Smash them into the Elleptic Curve Digital Signature Algorithm (ECDSA)
   1. It ourputs v,r,s values
   2. We can use these values to verify the someones signature using `ecrecover` method

How verification works:

1. Get signed message
   1. Break into v,r,s values
2. Get the data which was signed
3. Use them as arguments to `ecrecover` method to verify the signature. If it returns the same address as you are expecting, then the signature is valid.
