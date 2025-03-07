# SIMD-0123 Proposal for an In-Protocol Distribution of Block Rewards to Stakers

The SIMD can be viewed [on Github](https://github.com/solana-foundation/solana-improvement-documents/blob/0131156ec2a189d2a570bb23631bf00c899d9dcf/proposals/0123-block-fee-distribution.md) and a governance [forum proposal](https://forum.solana.com/t/proposal-for-an-in-protocol-distribution-of-block-rewards-to-stakers/3295) has been posted.

The forum proposal text is also recorded [in this repository](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0123/PROPOSAL.md) for posterity.

The stake weight gathering process takes place in epoch 752 and the voting process will begin in epoch 753 and last until epoch 755.

The token distribution occurs via merkle distributor (see this repo). Validators need to [claim](https://github.com/laine-sa/solgov-distributor) their voting tokens using their identity account.

## Key addresses and hashes

### File hashes

Verify the `simd123-proposal.csv` file has a hash of `423fa6408e8f993dce6be61936ec823cc5c061ffc1af5db9a7400e0b0a83e42f`

```bash
sha256sum simd123-proposal.csv
```

To reproduce the CSV file:

You will need the feature proposal CLI: `cargo install spl-feature-proposal-cli`
and a random (unfunded) keypair: `solana-keygen new --outfile random.json`

```bash
spl-feature-proposal propose random.json
```

This creates a CSV file in your current directory called feature-proposal.csv. You can compare the shasum, but the order of recipients may differ in which case you need to first sort (note that sort behaves different on different machines so sort both files on the same machine, the hash once sorted will not match the one shown above, the important thing here is that the hashes of the two files match each other):

```bash
cat feature-proposal.csv | sort | sha256sum
cat simd123-proposal.csv | sort | sha256sum
```

You can also use the `check_stake_weights.sh` scripts in the /votes directory of this repository. Note you can only use this during epoch 752 as the on-chain stake weights will have changed after that, and that this script uses `jq` which has a rounding error. There will be a few validators appearing as not matching with a diff of 1 lamport, however a manual check against the RPC node will show the amount in the CSV is correct, and for one validator (MyVidster, identity `BjuD62v9RysrburpKb65UKeaAWRSFyi7pFLLxdE3dPv` there are two vote accounts reflecting the same identity, in the CSV they are combined but the check script looks at them independently, the sum of the check scripts diff outputs should match the CSV file, it is correct that the identity receives the combined amount of tokens as both vote accounts have active stake).

Verify the merkle tree has a hash of `41e3a6831499750b33ee580e3a2a15d08536a5728ffb1d4a6ac6e260cf269804`

```bash
sha256sum simd123-merkle-tree.json
```

The vote token mint address is `s1233un3oMnNWo4EuKsEjtV7QtXfimhybHMQP7GLPwM`

The total supply will be `379050125089013001` with 1349 participating validators.

To reproduce the merkle tree:

```bash
./target/release/cli --keypair-path /any/funded/keypair.json --rpc-url https://api.mainnet-beta.solana.com --mint s1233un3oMnNWo4EuKsEjtV7QtXfimhybHMQP7GLPwM create-merkle-tree --csv-path ./votes/simd0123/simd123-proposal.csv --merkle-tree-path simd-0123-merkle-tree-to-verify.json
```

This will generate a merkle tree which you can then compare against the one published here.

## Voting

Claim your voting tokens using your validator identity account by cloning this repo and building the cli with `cargo b -r --bin cli` (you can also build and use the cli from Jito's original repository). You will need the merkle tree json file in this directory and your identity keypair file:

```bash
./target/release/cli --rpc-url https://api.mainnet-beta.solana.com --keypair-path <YOUR KEYPAIR> --airdrop-version 0 --mint s1233un3oMnNWo4EuKsEjtV7QtXfimhybHMQP7GLPwM --program-id mERKcfxMC5SqJn4Ld4BUris3WKZZ1ojjWJ3A3J5CKxv claim --merkle-tree-path ./votes/simd0123/simd123-merkle-tree.json
```

You can verify your tokens are received with `spl-token balance s1233un3oMnNWo4EuKsEjtV7QtXfimhybHMQP7GLPwM --owner <YOUR KEYPAIR>`

Cast your vote with `spl-token transfer` to one of the following vote addresses:

**YES**
```bash
YESsimd123111111111111111111111111111111111
```

**NO**
```bash
nosimd1231111111111111111111111111111111111
```

**ABSTAIN**
```bash
ABSTA1Nsimd12311111111111111111111111111111
```

`spl-token transfer s1233un3oMnNWo4EuKsEjtV7QtXfimhybHMQP7GLPwM ALL <VOTE_ADDRESS>`

## Tally / Results
Use the tally.sh script in this directory to check the results at any time.

`bash tally.sh`
