# SIMD-0326 Proposal for the New Alpenglow Consensus Protocol

The SIMD can be viewed [on Github](https://github.com/solana-foundation/solana-improvement-documents/pull/326/files) and a governance [forum proposal](https://forum.solana.com) has been posted.

The forum proposal text is also recorded [in this repository](https://github.com/laine-sa/solgov-distributor/blob/master/votes/simd0326/PROPOSAL.md) for posterity.

The stake weight gathering process takes place in epoch 839 and the voting process will begin in epoch 840 and last until epoch 842.

The token distribution occurs via merkle distributor (see this repo). Validators need to [claim](https://github.com/laine-sa/solgov-distributor) their voting tokens using their identity account.

## Key addresses and hashes

### File hashes

Verify the `simd326-proposal.csv` file has a hash of `TBD`

```bash
sha256sum simd326-proposal.csv
```

To reproduce the CSV file:

You will need the feature proposal CLI: `cargo install spl-feature-proposal-cli`
and a random (unfunded) keypair: `solana-keygen new --outfile random.json`

```bash
spl-feature-proposal propose random.json
```

This creates a CSV file in your current directory called feature-proposal.csv. You can compare the shasum, but the order of recipients may differ in which case you need to first sort (note that sort behaves different on different machines so sort both files on the same machine, the hash once sorted will not match the one shown above, the important thing here is that the hashes of the two files match each other)):

```bash
cat feature-proposal.csv | sort | sha256sum
cat simd326-proposal.csv | sort | sha256sum
```

You can also use the `check_stake_weights.sh` scripts in the /votes directory of this repository. Note you can only use this during epoch 839 as the on-chain stake weights will have changed after that, and that this script uses `jq` which has a rounding error.

Verify the merkle tree has a hash of `TBD`

```bash
sha256sum simd326-merkle-tree.json
```

The vote token mint address is `s3262ckXrLnzPXG8RScfFAYWDQzZYgnr4vo1R2SboMW`

The total supply will be `TBD` with TBD participating validators.

To reproduce the merkle tree:

```bash
./target/release/cli --keypair-path /any/funded/keypair.json --rpc-url https://api.mainnet-beta.solana.com --mint s3262ckXrLnzPXG8RScfFAYWDQzZYgnr4vo1R2SboMW create-merkle-tree --csv-path ./votes/simd0326/simd326-proposal.csv --merkle-tree-path simd-0326-merkle-tree-to-verify.json
```

This will generate a merkle tree which you can then compare against the one published here.

## Voting

Claim your voting tokens using your validator identity account by cloning this repo and building the cli with `cargo b -r --bin cli` (you can also build and use the cli from Jito's original repository). You will need the merkle tree json file in this directory and your identity keypair file:

```bash
./target/release/cli --rpc-url https://api.mainnet-beta.solana.com --keypair-path <YOUR KEYPAIR> --airdrop-version 0 --mint s3262ckXrLnzPXG8RScfFAYWDQzZYgnr4vo1R2SboMW --program-id mERKcfxMC5SqJn4Ld4BUris3WKZZ1ojjWJ3A3J5CKxv claim --merkle-tree-path ./votes/simd0326/simd326-merkle-tree.json
```

You can verify your tokens are received with `spl-token balance s3262ckXrLnzPXG8RScfFAYWDQzZYgnr4vo1R2SboMW --owner <YOUR KEYPAIR>`

Cast your vote with `spl-token transfer` to one of the following vote addresses:

**YES**
```bash
YESsimd326111111111111111111111111111111111
```

**NO**
```bash
nosimd3261111111111111111111111111111111111
```

**ABSTAIN**
```bash
ABSTA1Nsimd32611111111111111111111111111111
```

`spl-token transfer s3262ckXrLnzPXG8RScfFAYWDQzZYgnr4vo1R2SboMW ALL <VOTE_ADDRESS>`

You can add an optional note with a comment or motivation for your vote by adding `--with-memo "Comment"`

## Tally / Results
Use the tally.sh script in this directory to check the results at any time.

`bash tally.sh`
