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
