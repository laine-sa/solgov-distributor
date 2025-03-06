# Summary
A new mechanism is proposed to allow validators to set a block reward commission and share part of their block revenue with their delegators and to receive their own block rewards to an account of their choice.

Commission rates from validator vote accounts will be used by the protocol to calculate post-commission rewards that will be automatically distributed to delegated stake accounts at the end of each epoch

Block rewards after commission will be distributed to an account of the validators choosing. The default will be the validator identity account. If a validator takes no action then block rewards will continue go to the Identity account.

# Motivation
Delegated stake directly increases the number of blocks that a validator is allocated in an epoch leader schedule but the core protocol doesn’t support diverting any of that extra revenue to stake delegators.

Due to the lack of core protocol support for distributing block revenue to stakers, validators have developed their own solutions which are not enforced by the core protocol. For example, some validators use NFTs or LSTs to distribute some amount of their block revenue, however this requires trust in the validator’s honesty and accuracy, while making it difficult to surface this information and accurately track resulting yields.

With the option to specify a collector account validators can improve operational security by diverting their revenue into a multisig or cold wallet rather than the identity hot wallet that sits on their servers.

Additionally the ability to specify arbitrary collector accounts, including PDAs, means that additional custom functionality and distribution mechanisms can be built on top of this, such as auto-conversion to USDC or a validator LST, or deployment to Defi.

# Changes in the spirit of this proposal
Should any changes be necessary to ensure a safe and functioning implementation, such changes will be permitted without further governance requirements so long as the spirit of the proposal is maintained.

# Voting Process
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

# Timeline
Epoch 747 - 751: Discussion period

Epoch 752: Stake weights captured and published, discussion/confirmation of stake weights

Epochs 753 - 755: Voting tokens available to claim, voting completes at the end of epoch 755

# Discussion
Active participation in discussions about this proposal is crucial. Discussions may also take place on the Solana Developer Forums or on Discord Governance channel. It’s encouraged to consolidate discussions to ensure broad participation and minimize redundancy.

# References
https://github.com/solana-foundation/solana-improvement-documents/pull/123/
https://github.com/laine-sa/solgov-distributor 