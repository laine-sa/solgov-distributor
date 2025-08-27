# Token Mint And Distribution

## Token Mint

To mint the vote tokens one needs a funded keypair to pay the fees as well as the SIMD token mint. Verify the total supply that was output by the merkle tree generation and double-check this against known active stake as well as the total of the CSV file. 

The tokens can be minted prior to the start of the voting epoch, any nefarious activity with the minted tokens can be traced on-chain. The distributor can also be created ahead of time as long as the vesting time is set to the epoch start time.

Slight discrepancies may occur throughout the stake capture epoch as a result of split stake and merged stake accounts.

First create the token with 0 decimals and using the original token standard:

```bash
spl-token create-token --decimals 0 -p TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA <TOKEN_MINT_KEYPAIR>
```

Now create an associated token account (ATA) for the signing keypair to receive the initial minted tokens

```bash
spl-token create-account <TOKEN_MINT>
```
Now mint the tokens

```bash
spl-token mint <TOKEN_MINT_KEYPAIR> <MINT_AMOUNT>
```

Now we need to check the signature provided in an explorer such as the Solana Explorer, check the instructions in Raw view and look for the amount field. Due to the very large amount minted there is imprecision in the CLI and RPC calls which often leads to an incorrect mint amount that differs from what you passed in the CLI above, often in the single digits shortfall. Verify this across 2-3 explorers and in the CLI using `spl-token accounts`, then mint the missing balance

```bash
spl-token mint <TOKEN_MINT_KEYPAIR> <MINT_BALANCE>
```

When we verify the balance in the CLI with `spl-token accounts` it should now be correct. Note that some explorers round or abbreviate the balances so be sure to check the raw instructions and use the amount field, not the uiAmount field.


## Distributor creation

We need to build the binaries in this repo with `cargo b -r` and use the `cli` to create a new on-chain distributor.

The distributor can be created ahead of time, as claims will not be possible until the vesting time has been reached and the vault has been funded. We will need to know the following variables to create the distributor:

- Token mint public key (the CLI won't accept a keypair)
- A funding keypair
- An RPC URL
- The token account for a clawback receiver which can clawback tokens after the clawback time has passed (suggest using the one you minted tokens to)
- The vesting start time (use a website like [epochconverter.com](epochconverter.com) combined with the current epoch time to find a time 5-10 minutes after the voting epoch begins)
- The vesting end time (use start time + 1 as there is no need for ongoing vesting, but it has to be greater than start time)
- The clawback time (at least 2-3 days after the end of the last voting epoch, or even years into the future as you don't really need to ever clawback tokens)
- The markle tree path

The following assumes you're in the base directory of this repository:

```bash
./target/release/cli --mint <TOKEN_MINT> --
rpc-url <RPC_URL> --keypair-path <FUNDING_KEYPAIR>  new-distributor --clawback-receiver-token-account <FUNDING_KEYPAIR_TOKEN_ATA> --start-vesting-ts <VESTING_START_TIME> --end-vesting-ts <VESTING_END_TIME> --merkle-tree-path votes/simdXXXX/simdXXX-merkle-tree.json --clawback-start-ts <CLAWBACK_START_TIME>
```

Once this transaction is processed look up the transaction in your preferred explorer (the CLI won't output the signature once complete, look it up using your funding keypair pubkey), check the log for the "Vault" address. This is where you need to send the tokens when ready to enable users to claim them.

When ready (after voting epoch begins, preferably) transfer the tokens to the vault:

```bash
spl-token transfer <TOKEN_MINT> ALL <VAULT_PUBKEY> --allow-unfunded-recipient --fund-recipient
```

> [!NOTE]
> You can complete most of these steps on devnet to test and verify. Even before creating the distributor you can transfer test tokens on devnet to the vote destination accounts in order to find the ATA addresses to plug into the values.env file for the respective vote.