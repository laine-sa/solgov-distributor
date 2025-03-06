This proposal is updated in Epoch 750 to change the full rollout of emissions formula from 10 epochs to 50 epochs based on community feedback. Based on rough consensus achieved on Discord, there won’t be any change to the discussion period and voting will continue as per the original schedule.

Authors: Tushar Jain, Vishal Kankani, Max Resnick

# Background

As Solana matures, stakers increasingly earn SOL through mechanisms like MEV. This income stream reduces the network’s historical exclusive reliance on token emissions to attract stake and security. According to Blockworks (https://solana.blockworksresearch.com/), in Q4 2024 MEV, as measured by Jito Tips, was approximately $430M (2.1M SOL),representing massive quarter-over-quarter growth. In Q3 Jito Tips were approximately $86M (562k SOL), Q2 was approximately $117M (747k SOL), and Q1 was approximately $42M (300k SOL).

Given the level of economic activity the network has achieved and the subsequent revenue earned by stakers from MEV, now is a good time to revisit the network’s emission mechanism and evolve it from a fixed-schedule mechanism to a programmatic, market-driven mechanism.

The purpose of token emissions in Proof of Stake (PoS) networks is to attract stakers and validators to secure the network. Therefore, the most efficient amount of token issuance is the lowest rate possible necessary to secure the network.

Solana’s current emission mechanism is a fixed, time-based formula that was activated on epoch 150, a year after genesis on February 10, 2021. The mechanism is not aware of network activity, nor does it incorporate that to determine the emission rate. Simply put, it’s “dumb emissions.” Given Solana’s thriving economic activity, it makes sense to evolve the network’s monetary policy with “smart emissions.”

There are two major implications of Smart Emissions:

1. Smart Emissions dynamically incentivizes participation when stake drops to secure the network.
2. Smart Emissions minimize SOL issuance to the Minimum Necessary Amount (MNA) to secure the network.

This is good for the Solana network and network stakers for four reasons:

High inflation can lead to more centralized ownership. To illustrate the point, imagine a network with an exceedingly high inflation rate of 10,000%. People who do not stake are diluted and lose ~99% of their network ownership every year to stakers. The higher the inflation rate, the more network ownership is concentrated in stakers’ hands after compounding for years.

Reducing inflation spurs SOL usage in DeFi, which is ultimately good for the applications and stimulates new protocol development. Additionally, a high staking rate can be viewed as unhealthy for new DeFi protocols, since it means the implied hurdle rate is the inflation cost. Lowering the “risk free” inflation rate creates stimulative conditions and allows new protocols to grow.

If Smart Emissions function as designed, they will systematically reduce selling pressure as long as staking participation remains adequate. The inevitable side effect and primary downside to high token inflation is increased selling pressure. This is because some stakers in different jurisdictions have taken the interpretation that staking creates ordinary income, and therefore they must sell a portion of their staking rewards to pay taxes. This selling is a significant detriment to the network and does not benefit the network in any way. At today’s approximate 4.5% annualized inflation, at a $120 billion fully diluted valuation, new emissions amount to ~USD 5.5 billion per year.

In markets, sometimes perception is as important as reality. While SOL inflation is technically not cost to the network, others think it is, and that belief overall has a negative impact on the network. Inflation causes long-term, continual downward price pressure that negatively distorts the market’s price signal and hinders fair price comparison. To use an analogy from traditional financial markets, PoS inflation is equivalent to a publicly listed company doing a small share split every two days.

Historically, issuance curves have remained static due to Bitcoin’s immutability ethos—a “Bitcoin Hangover” so to speak. While immutability suits Bitcoin’s mission to become digital gold, it doesn’t map to Solana’s mission to synchronize the world’s state at light speed.

In summary, the current Solana emissions schedule is suboptimal given the current level of activity and fees on the network because it emits more SOL than is necessary to secure the network. An issuance curve set by diktat is not the right long-term approach for Solana. Markets are the best mechanism in the world to determine prices, and therefore, they should be used to determine Solana’s emissions.

For the sake of clarity, this proposal for SIMD-0228 is independent of other SIMDs under discussion currently. It can be executed standalone.

# Testing

Based on our discussions with Anza and with core engineers the community call, there is an understanding that this is a straightforward technical update and poses no technical risks. Upon approval of the proposal, we will collaborate with Anza, the Solana Foundation, and the Jump/Firedancer teams on implementation.

# Proposal

We propose updating the emissions rate formula to more accurately capture the market dynamics.

List of variables:

Fraction of total supply staked: (s)
Issuance Rate (i)
Validator returns: v(s) = i/s + MEV
r is the current emissions curve that automatically goes down every epoch at an annualized rate of 15% every year until it reaches 1.5% where it stops changing.
The suggested new formula and curve is:
![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/new%20formula.png?raw=true)
![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/new%20issuance%20rate.png?raw=true)

When s > .5 the curve corresponds to just the first term: r(1 - sqrt(s)). This was the curve in the previous version of the SIMD. Based on community feedback, we have added the cmax(1-sqrt(2s),0) term to make the curve more aggressive when a smaller fraction of the network is staked. c is chosen such that the curve starts becoming more aggressive at s =.5, when half of the supply is staked, and surpasses the current static emission schedule of r when s = 1/3.

The derivation of c is provided in the appendix.

This yields a vote reward rate for validators with good performance of:

![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/staking%20yield.png?raw=true)
![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/staking%20returns%20over%20time.png?raw=true)

To ensure that the transition from the old static issuance schedule to this new schedule is smooth, we will interpolate between the old issuance rate and the new issuance rate over 50 epochs using the formula:
![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/new%20phase-in%20formula.png?raw=true)

where “alpha” is a parameter that controls the speed of the transition, taking the values 1/50, 2/50, …, 49/50, 1, over the first 50 epochs before settling to the new issuance rate at = 1.
![New curve](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0228/issuance%20rate%20during%20rollout.png?raw=true)

# Alternatives Considered

We considered a few alternatives and decided to settle upon the above curve.

Alternative Design 1: Pick another fixed curve. We rejected it because replacing one arbitrary curve with another arbitrary curve makes little sense.

Alternative Design 2: Fix Target Staking Yield inclusive of emissions and MEV payments. We rejected this approach because it incentivizes MEV payments to move out of sight of the tracking mechanism, thereby rendering the design completely ineffective, and impossible to implement.

Alternative Design 3: A controller function that increases or decreases inflation proportional to the magnitude of the difference between the actual staking participation rate and the target rate (for example, 50%). While this approach would have allowed for a more dynamic response to fluctuations in staking participation, it risks putting emissions back to current highs even if staking participation rate organically went below the target rate (for example, 50%)

Alternative Design 4: We considered only the first term of the proposed formula above. But that left the specific edge case of existing emissions curve unaddressed. That edge case was if at a future date staking rate continues to drop, and the terminal inflation hits 1.5%, then how would the network be secure. Hence, we added the second term to let the inflation increase beyond what is implied by the current curve in such an edge case scenario.

After considering all these options, we believe the proposed static curve is the most appropriate solution to address our inflation concerns as it is market-based, programmatic, and a function of a market variable.

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

SIMD-0228: solana-improvement-documents/proposals/0228-market-based-emission-mechanism.md at patch-1 · tjain-mcc/solana-improvement-documents · GitHub