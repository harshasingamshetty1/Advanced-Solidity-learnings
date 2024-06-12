## Misc

Change State Variables to Immutable Where Possible
Solidity 0.6.5 introduced immutable as a major feature. It allows setting contract-level variables at construction time which gets stored in code rather than storage.

Here’s an example:

contract C {
/// The owner is set during contruction time, and never changed afterwards.
address public owner = msg.sender;
}
In the above example, each call to the function owner() reads from storage, using a sload. After EIP-2929, this costs 2100 gas cold or 100 gas warm. However, the following snippet is more gas efficient:

````solidity
contract C {
# The owner is set during contruction time, and never changed afterwards.
address public immutable owner = msg.sender;
}

In the above example, each storage read of the owner state variable is replaced by the instruction push32 value, where the value is set during contract construction time. Unlike the last example, this costs only 3 gas.

Change Constant to Immutable for keccak Variables
The use of constant keccak variables results in extra hashing (and so gas). This results in the keccak operation being performed whenever the variable is used, increasing gas costs relative to just storing the output hash. Changing to immutable will only perform hashing on contract deployment which will save gas. You should use immutables until the referenced issues are implemented, then you only pay the gas costs for the computation at deploy time.

> = is cheaper than >
> Non-strict inequalities (>=) are cheaper than strict ones (>). This is due to some supplementary checks (ISZERO, 3 gas)).

```solidity
uint256 public gas;
function check1() external {
gas = gasleft();
require(99999999999999 != 0); // gas 22136 --disabled optimizer
gas -= gasleft();
}
````

```solidity
function check2() external {
gas = gasleft();
require(99999999999999 > 0); // gas 22136 --disabled optimizer
gas -= gasleft();
}
```

```solidity
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

```
