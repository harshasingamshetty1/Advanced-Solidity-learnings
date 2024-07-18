Everybody knows, what Aaccount abstraction is but just to simply put, AA is not having to deal with private keys anymore for handling your wallet.

Okay, diving into the juicy stuff now.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/25.png?raw=true)

Traditionally, the transaction is done by an EOA (externally owned account) and it is sent to the Ethereum node

But now, for AA you no longer send the txn to the node instead you send it to Alternate mem pools.

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/26.png?raw=true)

Now these alt mem pool nodes are the ones that first validate your user operation and send it to the EntryPoint.sol contract.

And the EntryPoint.sol contract will call the contract which was created according to your rules to authenticate, it can be google sign in, etc.

## In Depth

![alt text](https://github.com/harshasingamshetty1/advanced-solidity-learnings/blob/main/resources/24.png?raw=true)

1. Create a SC that defines, "what" can sign a transaction. This new contract will become the user wallet
2. Now, to send a txn the user must send the UserOp and these are formed into a struct and then the alt mem pool nodes will send this data to the EntryPoint.sol contract.

3. Here, we can have optional settings configured in our Account contract, like signature aggregators which can be used to allow txn only when multiple users sign it.
4. Also, optional Pay master account can be configured. Understand that when the user initiates the txn, he does not pay the gas as in traditional EOA txns. bcoz here, the Alt mem pools are the one's that are sending the txn and hence they pay it.

5. So, with AA its very easy to setup the Gasless user experience. We can configure who is gonna pay the txn fee in the Account.soll contract.
