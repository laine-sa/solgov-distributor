# Proposal for the New Alpenglow Consensus Protocol

Authors: Quentin Kniep, Kobi Sliwinski, Roger Wattenhofer

## Summary

Alpenglow is a major overhaul of Solana’s core consensus protocol, replacing the existing Proof-of-History and TowerBFT mechanisms with a modern architecture focused on performance, resilience, and whenever possible simplicity.

At the heart of this new design is *Votor*, a lightweight, direct-vote-based protocol that finalizes blocks using either a single or dual-round voting process, depending on network conditions. Alpenglow significantly reduces latency (from 12.8 seconds under TowerBFT to as low as 100-150 milliseconds) while also improving bandwidth efficiency by eliminating heavy gossip traffic. The protocol introduces a robust certification mechanism, with different certificate types corresponding to notarizating, skipping, or finalizing blocks based on validator votes. To support this, validators will exchange votes directly, using cryptographic aggregates to prove consensus. *Rotor*, Alpenglow's new data dissemination protocol, will be introduced in a later update, the current rollout focuses on finalization and voting logic. 

This forum post only outlines the most important aspects of Alpenglow. On all the topics below, there is much more detailed information available. In particular we recommend reading the actual Alpenglow white paper: https://github.com/rogerANZA/Alpenglow-White-Paper/blob/main/Alpenglow-v1.1.pdf .

However, there is also a list of additional information available:

- Original Alpenglow blog entry: https://www.anza.xyz/blog/alpenglow-a-new-consensus-for-solana
- Alpenglow SIMD with a special focus on rewards and incentives, and its discussion: https://github.com/solana-foundation/solana-improvement-documents/pull/326 
- Various third party analyses, e.g., https://www.helius.dev/blog/alpenglow or https://blog.sei.io/solanas-alpenglow-a-faster-consensus-with-new-trade-offs/ 
- Discord discussion channel: https://discord.com/channels/428295358100013066/1377667311174946816 


## Motivation
The move to Alpenglow is driven by the need to address both performance and security limitations in Solana’s legacy consensus protocol TowerBFT. TowerBFT imposes long finality delays and lacks formal safety guarantees. Alpenglow is designed with insights from recent advances in distributed systems and blockchain research, enabling much lower latency, improved fault tolerance, and generally greater protocol efficiency. The introduction of direct voting, local signature aggregation, and off-chain vote messaging substantially cuts down on unnecessary computation and communication costs. Furthermore, Alpenglow addresses key incentive flaws in the previous system—such as validators delaying votes for strategic gain—by rebalancing economic rewards and introducing mechanisms like the Validator Admission Ticket (VAT) to maintain fair participation without on-chain vote fees. Its "20+20" resilience model allows the protocol to remain live even if up to 20% of validators are adversarial and another 20% are unresponsive. In short, Alpenglow brings consensus latency to a level comparable with Web2 applications while strengthening the system’s security posture, scalability, and economic fairness.

## Protocol Overview

Let us outline Alpenglow from a broad perspective. The protocol operates across a large network of nodes which may number in the thousands. These nodes are part of a defined validator set that remains stable throughout a period known as an epoch. Each node can directly communicate with any other node in the network by sending messages.

Alpenglow functions as a proof-of-stake blockchain, meaning that each node has an associated amount of stake, which reflects its level of participation and influence. Nodes with greater stake have proportionally higher responsibilities and rewards, including contributing more bandwidth and earning higher fees.

Time is divided into discrete intervals called slots. Every slot is assigned a specific leader, chosen in advance using a randomized, verifiable process. Each leader is responsible for a sequence of consecutive slots, referred to as their leader window. During this window, the leader collects transactions from users and from other nodes and uses them to create a new block.

Blocks are built in a pipelined fashion: they are split into intermediate units known as slices, which are further divided into smaller pieces called shreds. Initially, these shreds are dispersed across the network using Turbine. Later, we will replace Turbine with the more efficient Rotor. (Rotor will need to pass its own SIMD process.)

Once a block is constructed, the following leader begins producing the next block without delay. Meanwhile, all nodes receive the newly created block and store its data using a dedicated storage system. After receiving a block, nodes begin the voting process to signal whether they accept it. This involves a range of vote types and corresponding aggregated proofs, which are maintained in a local structure that tracks voting history and progress.

The core voting logic (Votor) decides whether a block should be finalized. If a node receives the block in a timely and valid form, it will cast a vote in favor. If the block is delayed or invalid, the node will vote to skip it. Finalization occurs when a sufficient portion of the stake affirms the block. If consensus isn't reached in the first round of voting, a fallback round may be used to determine whether the block should be skipped or accepted.

In cases where a node misses data—such as shreds or entire blocks—there is a “Repair” recovery mechanism that allows it to request missing information from other nodes, ensuring data completeness and integrity even in the presence of faults or delays.

Together, these components form the foundation of Alpenglow’s consensus protocol, aiming for high performance, strong fault tolerance, and efficient operation at scale. Since a 50+ page document can only be summarized, we encourage reading the actual detailed documentation: https://github.com/rogerANZA/Alpenglow-White-Paper/blob/main/Alpenglow-v1.1.pdf. 


## Rewards and Incentives

Alpenglow introduces a revamped rewards and incentive system that aligns with its new consensus design, aiming to preserve economic fairness, eliminate inefficiencies, and reinforce active participation. Under the previous protocol, validators submitted on-chain vote transactions for each slot, incurring significant overhead in bandwidth, transaction fees, and processing load. Alpenglow replaces this system with off-chain voting and efficient signature aggregation, dramatically reducing the cost and complexity of participation while maintaining reward fairness.

Each validator’s reward is proportional to their stake, as in traditional proof-of-stake systems. For every voting action a validator performs, they receive a portion of the protocol’s inflationary issuance. This issuance is calculated per slot and distributed based on stake weight. In each slot, a validator casts one of two possible votes (e.g., in favor of a block or to skip it), and these are collected and aggregated by the designated leader 8 slots in the future. 

To ensure validators remain engaged and do not game the system, Alpenglow introduces stricter rules and more transparent accountability. Validators are required to cast exactly one valid vote per slot. Submitting conflicting votes is detectable. Validators that fail to participate are not eligible for rewards and risk being excluded from the active set of validators.

A mechanism introduced alongside this new model is the Validator Admission Ticket (VAT). Since voting is no longer posted on-chain (and hence no longer requires direct transaction fees), the VAT serves as an upfront cost to maintain an equivalent economic barrier. Before each epoch, each validator must pay a fixed fee—initially set to 1.6 SOL per epoch. This fee is non-refundable and burned, helping to offset inflation while preserving the economic dynamics of the current system. If a validator does not hold sufficient balance to cover the VAT, it is removed from the validator set.

Leaders also receive compensation for their role in aggregating and submitting vote data. For each valid aggregate they submit (either notarization or skip votes), the leader earns a reward equal to that of all votes included in the aggregate. Additionally, leaders are rewarded with a flat bonus for including fast-finalization or finalization certificates, recognizing the higher computational cost of processing aggregate signatures. These rewards and incentives are described in more detail in the SIMD: https://github.com/solana-foundation/solana-improvement-documents/pull/326 


## Voting Process 

The voting process will proceed as follows:

Discussion period: Validators are encouraged to participate in discussions to address any concerns.

Stake weight collection period: Stake weights will be captured and published for voting. Validators will have the opportunity to verify these weights.

Vote token distribution will require validators to utilize the adapted Jito Merkle Distributor tool (available at GitHub - laine-sa/solgov-distributor: A merkle-based token distributor for the Solana network that allows distributing a combination of unlocked and linearly unlocked tokens.) to claim the vote tokens corresponding to their stake weights.

Three token destination accounts will be created for voting choices: Yes, No, and Abstain.

Validators will have a designated period to vote by sending their tokens to the respective addresses.

After the voting period, if the sum of Yes votes is equal to or greater than 2/3 of the total sum of Yes + No votes, the proposal will pass.

The proposal has a quorum threshold of 33%, abstentions count towards the quorum.

All announcements regarding this process will be made in the Governance category of the Solana Developer Forums.

Stake weights and a tally script will be available at solgov-distributor/votes at master · laine-sa/solgov-distributor · GitHub


## Timeline

Epoch 833–838: Discussion period

Epoch 839: Stake weights captured and published, discussion/confirmation of stake weights

Epochs 840–841: Voting tokens available to claim, voting completes at the end of epoch 841


## Discussion 

Active participation in discussions about this proposal is crucial. Discussions may also take place in the various forums and channels mentioned at the beginning.
