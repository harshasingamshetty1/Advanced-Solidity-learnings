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

## Misc

Change State Variables to Immutable Where Possible
Solidity 0.6.5 introduced immutable as a major feature. It allows setting contract-level variables at construction time which gets stored in code rather than storage.

Here’s an example:

contract C {
/// The owner is set during contruction time, and never changed afterwards.
address public owner = msg.sender;
}
In the above example, each call to the function owner() reads from storage, using a sload. After EIP-2929, this costs 2100 gas cold or 100 gas warm. However, the following snippet is more gas efficient:

contract C {
/// The owner is set during contruction time, and never changed afterwards.
address public immutable owner = msg.sender;
}
In the above example, each storage read of the owner state variable is replaced by the instruction push32 value, where the value is set during contract construction time. Unlike the last example, this costs only 3 gas.

Change Constant to Immutable for keccak Variables
The use of constant keccak variables results in extra hashing (and so gas). This results in the keccak operation being performed whenever the variable is used, increasing gas costs relative to just storing the output hash. Changing to immutable will only perform hashing on contract deployment which will save gas. You should use immutables until the referenced issues are implemented, then you only pay the gas costs for the computation at deploy time.

> = is cheaper than >
> Non-strict inequalities (>=) are cheaper than strict ones (>). This is due to some supplementary checks (ISZERO, 3 gas)).

uint256 public gas;
function check1() external {
gas = gasleft();
require(99999999999999 != 0); // gas 22136 --disabled optimizer
gas -= gasleft();
}
function check2() external {
gas = gasleft();
require(99999999999999 > 0); // gas 22136 --disabled optimizer
gas -= gasleft();
}
function check3() external {
gas = gasleft();
if (99999999999999 != 0){ // 22149 gas --disabled optimizer
uint256 i = 123;
}
gas -= gasleft();
}
function check4() external {
gas = gasleft();
if (99999999999999 > 0){ // 22152 gas --disabled optimizer
uint256 i = 123;
}
gas -= gasleft();
}
view rawcheck1.sol hosted with ❤ by GitHub

```

```
