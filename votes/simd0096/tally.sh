#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"
RPC_URL="https://api.mainnet-beta.solana.com"

MINT="simd96Cuw3M5TYAkZ1d71ug4bvVHiqHhhJzsFHHQxgq"
YES_ACCT="7CrAvWEASABRgakuK9M8DkTK7wJieMurf59eWaFzX7P9"
NO_ACCT="5BE5U1eZfoeWTerBp9mBBqE2WHnscdWey4sceEM1ojRu"
ABSTAIN_ACCT="ARjw39v3Y6QWK7WaWdTEKqiFDym1S2gTmXykbWRDFUx4"

function fetch_vote_token_balance() {
        if ! curl -s $RPC_URL -X POST -H "Content-Type: application/json" -d \
                '{ "jsonrpc": "2.0", "id": 1, "method": "getTokenAccountBalance", "params": ["'"$1"'"] }' | jq ".result.value.uiAmountString" | tr -d '"'; then
                echo "ERROR: curl failed"
                exit 1
        fi
}

function fetch_total_supply() {
        if ! curl -s $RPC_URL -X POST -H "Content-Type: application/json" -d \
                '{ "jsonrpc": "2.0", "id": 1, "method": "getTokenSupply", "params": ["'$MINT'"] }' | jq ".result.value.uiAmountString" | tr -d '"'; then
                echo "ERROR: curl failed"
                exit 1
        fi
}

function print_row() {
        printf '%8s  |  %8.4f%%  |  %20d\n' "$1" "$2" "$3"
}

YES=$(fetch_vote_token_balance $YES_ACCT)
NO=$(fetch_vote_token_balance $NO_ACCT)
ABSTAIN=$(fetch_vote_token_balance $ABSTAIN_ACCT)
TOTAL=$(echo "$YES + $NO + $ABSTAIN" | bc)
SUPPLY=$(fetch_total_supply)
YES_PCT=$(echo "scale=4; $YES / $SUPPLY * 100" | bc)
NO_PCT=$(echo "scale=4; $NO / $SUPPLY * 100" | bc)
ABSTAIN_PCT=$(echo "scale=4; $ABSTAIN / $SUPPLY * 100" | bc)
TOTAL_PCT=$(echo "scale=4; $TOTAL / $SUPPLY * 100" | bc)

print_row "YES" "$YES_PCT" "$YES"
print_row "NO" "$NO_PCT" "$NO"
print_row "ABSTAIN" "$ABSTAIN_PCT" "$ABSTAIN"
echo ""
print_row "CASTED" "$TOTAL_PCT" "$TOTAL"
print_row "SUPPLY" "100" "$SUPPLY"
