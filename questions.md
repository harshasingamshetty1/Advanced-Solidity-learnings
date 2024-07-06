# ⁠ ⁠An Ethereum contract is funded with 1,000 ETH. It costs 1 ETH to call, which is added to the balance. If the contract isn’t called for 10 blocks, the last caller gets the entire ETH balance. How might this game unfold and end? Describe your thinking.

The game initially appears highly attractive to everyone due to the lucrative reward, so most people try to participate.

And eventually, individuals might use strategies like, to time the transactions, when the network is least busy, hoping that no one is online and might win the reward. But, it does not work as there are people all around the world playing the game.

As the game progresses, the reality starts to kick in that, the players are not going to let any one win, in the hope of they winning it for themselves.

This realization leads smaller players to drop out after incurring significant ETH losses, transforming the game into a contest primarily among wealthy "whales" with substantial disposable funds.

Lets explore a hypothetical scenario which explains a potential winning strategy for a well-resourced organization:

Given Ethereum's block gas limit of 30 million and the gas cost of a simple ETH transfer (21,000), each block can accommodate approximately 1,429 ETH transfers, totaling 14,290 transactions over 10 blocks (potentially even fewer with complex smart contract interactions). This number is manageable for a large, coordinated effort.

They start the plan after a significant time, when most of the small accounts have dropped of the game, and the pool might have a significant amounth of ETH maybe around 25,000ETH. (which is pretty huge.)

Now the plan is to first select a time when there is least traffic and then:

1. Execute one transaction to the game contract.(ensuring you are the last caller)
2. Flooding the network with numerous other high-gas transactions.
3. Even If someone else attempts to call the game contract, immediately submitting multiple transactions with even higher gas fees. (This helps, as the validators choose the txns with highest gas fee first)
4. Maintaining this congestion for at least 10 blocks to prevent any other game contract interactions.

Ofcourse this needs a lot of funds and might need a big team to orchestrate this plan.
But theoretically speaking this definitely presents a viable method to win by controlling network congestion for the critical 10-block period.

conclusion: I feel best strategy to win this game for an average person is to not play at all, because the chances of you loosing a lot of ETH is extremely high compared to the chances of you winning the loot.

Eventually, this game becomes a game for big whales, with significant resources and winning will be feasible to those, who are able to control the the order of txns that are picked by the validators.
