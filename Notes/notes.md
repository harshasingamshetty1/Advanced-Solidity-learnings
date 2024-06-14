Udemy course: Advanced Solidity: Understanding and Optimizing Gas Costs

# Section: Overview of gas cost

function selector is the first 4 bytes of the keccak256 hash of the function signature. So we can just pass this data even in metamask and do the txn, we need not use any UI to interact with smart contracts if we know the function signatures

in a txn, the msg.data value (bcoz it will be stored forever on chain) takes up 4 gas for a zero value i.e 0x00
and takes up 16 gas for each byte of data. i.e 0x01 in the msg.data takes up 16 gas.
source=> yellow paper (G-txdatazero = 4gas, G-txdatanonzero= 16gas)

Deployed a simple contract with only single function.

`function doNothing() external payable{}` with optimization enabled to 1000 runs.

Now, a txn to the doNothing() took exactly 21138 gas.
Lets dive in, how we got that amount exactly.

First thing, As we know basic any txn on EVM, takes 21,000 gas.
And if we just add up all the gas using the remix debugger it takes exactly "65" gas to load all the data, jump to the location of doNOthing() method etc..

Second is, as we have called the doNothing() function. which means the function selector is passed in the msg.data
as we know that function selector is 4 bytes long and also from the yellow paper understood that, each byte takes up 16 gas.
Therefore, 64 gas. adds up to current total of 21,129 gas

Where is the remaining 9 gas ? (bcoz total was 21138)

Lets find out:

push 0x80, push 0x40, MStore, this is done for every txn, as a compiler specification.

Mstore(location, value), therefore storing (0x80) at the storage (0x40)

Memory layout structure: (understand each slot is 32 bytes)
0-0x20 -> 1st slot (0-32 bytes)
20-0x40 -> 2nd slot
0x40-0x60 -> 3rd slot
etc.

so now, above we are storing 0x80 at 0x40 which is the 3rd slot.

```bash
Solidity reserves four 32-byte slots, with specific byte ranges (inclusive of endpoints) being used as follows:

0x00 - 0x3f (64 bytes): scratch space for hashing methods

0x40 - 0x5f (32 bytes): currently allocated memory size (aka. free memory pointer)

0x60 - 0x7f (32 bytes): zero slot
```

All this is done by compiler, irrespective of what u do, and for every byte of memory allocation it takes 3 gas.
and here as we are pushing into 3rd slot, therefore we are reserving 3 slots
and hence 9 gas is used up!

The above doNothing() function has been made payable, so it has less cost.

This is bcoz, when we do not have payable keyword, then when a txn is initiated, there are checks happening to see is msg.value is 0 or not, and reverts if msg.value != 0 , and hence it takes more gas for this check.

but when func is payable, msg.value can be anything, including 0. therefore, no need of any checks and hence less gas.

1. till solidity 0.8, there was no built in arithmatic check, so there used to be overflow and underflow possible.
   i.e
   uint8 a = 255
   a += 1

now, a would become 0. due to overflow

but after 0.8 Solidity, the txn gets reverted if something like that happens, coz it has got some built in checks at the bytecode level.

and hence, we can save some gas (~ 7gas for each increment), if can have unchecked blocks in loops.
this must be done, only in cases, when u think that, there is no way of the value getting overflowed.

2. THe 21,000 gas must be payed for any txn whatsoever. this is bcoz, the EVM nodes have got some overhead to be checked.
   They are
   a. The txn is well formed, without any trailing zeroes.
   b. The nonce is valid.
   c. THe txn signature is valid.
   d. The sender acc bal has sufficient gas for up front payments.

So these are major factors which contribute to the 21,000 gas that is always present in any EVM txn.
Therefore, all the additional work, you do in your txn will be added to these base of 21k gas.

3. Base Fee is Dynamic based on the network congestion.
   If the Block is at almost at its limit, then the base fee increase by almost ~12%
   and when the block is relatively empty, it decreases like wise,

### Solidity Optimizer

Basically the optimizer has a parameter called num of runs.
This is a trade off parameter between the

1. deployment cost (length of bytecode generated) vs
2. The Cost of user interaction with the contract.

Ideally, the runs should be very high like 1mil if you think that, the contract would be heavily used by users, i.e the num of txns gonnna be crazy high, like Uniswap V3 it almost has 5M txns currently, they know that it would have so many txns happening and hence they have set the optimizer runs to 1million.

So, if the runs is low like 200 or so, then the deployment cost is low ( due to short bytcode.) and the user interaction cost is high.

## Storage Overiew Section

1. Setting storage var from zero to non-zero => ~20,000 gas (This is bcoz we need to index the value)
2. Setting storage var from non-zero to non-zero => ~5,000 gas (This is coz, we have already indexed but just have to change the value)[but its only ~100gas if we are just rewriting the same value]
3. Setting storage from non-zero to zero => ~ almost 0 gas (This is coz we are removing the index)[Check the refunds section for more info]

Cold storage read access ~2100 gas, i.e when storage var is loaded for 1st time in the txn.
warm storage read is just 100 gas which is almost negligible.
<br>
Important to add the cold storage, when you are accessing a var and modifying it to non zero, and hence essentially the above 20k would become 22.1k gas
<br><br>
**Key point: Each storage slot is 32bytes, so you cannot just use smaller size variables like u16 etc, to save gas. Rather you should arrange all the vars in your contract so that you take up as minimal slots as possible**

# Arrays

### case 1:

Lets say we are creating an array = [1] into storage, what's the gas cost ?<br>
21k => txn cost<br>
22,100 => to store the length <br>
22,100 => changing a value from zero to non zero (~20k) + 2.1k for cold storage of the 0th index
so total around 66k gas.<br>

now, if we are changing the array = [2,3]<br>
same as above 66k and 1 more element(22.1k) so, total around 87k<br>

Now, lets say new array = [2, 4]<br>

"**catch**": here, the 0th index element is not modified.
so,
21k => txn cost<br>
5k => increment the length this is not 22k bcoz we are changing a value from non zero to non zero<br>
22.1k => to store the new element<br>
2100 => cold access of 0th index<br>
100 => we are rewriting the same element so only 100 gas, it would be 5k if we have changed the value
<br>
so total around 51k gas

So its better to push into an array, if you are not going to change the values. it would save you around 2200 gas

## Refunds for setting var from non zero to zero [VM London]

1. You either get 4800 gas as refund or
2. you get 20% of total gas of your tx

You'll be paying whicher is the maximum of the above 2 gas values.

Ex: 1
lets say uint a = 1, is now changed to 0
in this case
21k => txn cost
5k => changing from non zero to non-zero (Though we are changing to 0, it still is counted, as we will be getting a refund)

200 => function handling costs

Total till here => 26200 gas

But, we will be pay

MAX (26200-4800 or 26200\*(0.8)) [understand that, we multuplied with 0.8 bcoz, case 2 is 20% refund]

In this scenario, MAX (21400, 20960)

Therefore, total gas => 21400 (case 1 is applied)

# Gas cost for ERC 20 transfers

3 main things that happen in a transfer are

1. Balance of sender is decreased
2. Balance of reciever is increased
3. An event is emitted (logs added to blockchain and hence must pay gas)

lets concentrate on 1 and 2. (all possible cases)

1. sender balance: nonzero to zero<br>
   Receiver bal: zero to nonzero<br>
   Total would become => 21k + 22k(receiver) + 5k -4.8k (refund) <br>
   =>46,686 (~invloves event emmission as well)

2. sender balance: nonzero to nonzero<br>
   Receiver bal: zero to nonzero<br>
   Total would become => 21k + 22k(receiver) + 5k <br>
   =>51,474 (~invloves event emmission as well)

Similarly if you calculate, its least expensive for the below case

3. sender balance: nonzero to zero<br>
   Receiver bal: nonzero to nonzero<br>
   Total would become => 21k + 5k(receiver) + 5k -4.8k (refund) <br>
   =>29,586 (~invloves event emmission as well)

## Storage Cost for files

Understand that,
1kb => 2^10 bytes
wkt, for each storage slot to change it from 0 -> non-zero, we need 22,100 gas.
and also wkt, each slot is 32 bytes.

So, therefore for 1kb => 32\*22100
=> nearly 700k gas
=> almost 100USD as per avg ETH price($3k)

Therefore, on average for just a 1kb file, it would need $100 gas price, which is pretty huuge.
Thereore, we must always choose to keep the **untamperable summaries of data like hash values**.
Instead of the raw files itself

## Variable packing

Common misconception: Its not always better pack the variables.
like uint128, uint128 into one storage slot.

Its bcoz, when we pack 2 vars into a single storage slot, then the evm must also do some calculations regarding the offset, bcoz when it loads the slot, it loads both the values, but to understand, which belongs to which var.
VM stores the offset value (its just some logic)

## MEMORY VS CALLDATA

Which is better and when ?

```Solidity
   function arr(bytes memory param) external pure returns(bytes memory ){
         return param;
      }

   function arr(bytes calldata param) external pure returns(bytes memory ){
         return param;
      }
```

Basically, the meaning of using memory is that, we want to copy the input(calldata) into our local memory.

And calldata, mean that you just want to use the input without copying it.

So now, Calldata is cheaper when you are not going to modify the input data.
But incase, you need to mutate the input data, then we must go with memory to save gas. Simple!
