#!/bin/bash
export LC_NUMERIC="en_US.UTF-8"
RPC_URL="https://api.mainnet-beta.solana.com"

if [[ -z $1 ]]; then
  echo "Usage:"
  echo "  ./tally.sh <SIMD-DIRECTORY>"
  echo "  example: ./tally.sh votes/simd0096"
  exit 1
fi

source "$1/values.env"

function fetch_vote_token_balance() {
    local balance
    balance=$(curl -s $RPC_URL -X POST -H "Content-Type: application/json" -d \
        '{ "jsonrpc": "2.0", "id": 1, "method": "getTokenAccountBalance", "params": ["'"$1"'"] }' | jq -r ".result.value.uiAmountString")

    if [[ -z "$balance" || "$balance" == "null" ]]; then
        echo "0"
    else
        echo "$balance"
    fi
}

function fetch_total_supply() {
    local supply
    supply=$(curl -s $RPC_URL -X POST -H "Content-Type: application/json" -d \
        '{ "jsonrpc": "2.0", "id": 1, "method": "getTokenSupply", "params": ["'$MINT'"] }' | jq -r ".result.value.uiAmountString")

    if [[ -z "$supply" || "$supply" == "null" ]]; then
        echo "1"  # Avoid division by zero by returning 1 instead of 0
    else
        echo "$supply"
    fi
}

function print_row() {
    printf '%8s  |  %8.4f%%  |  %20d\n' "$1" "$2" "$3"
}

YES=$(fetch_vote_token_balance "$YES_ACCT")
NO=$(fetch_vote_token_balance "$NO_ACCT")
ABSTAIN=$(fetch_vote_token_balance "$ABSTAIN_ACCT")
TOTAL=$(echo "$YES + $NO + $ABSTAIN" | bc)
SUPPLY=$(fetch_total_supply)

# Prevent division by zero
if [[ "$SUPPLY" -eq 0 ]]; then
    SUPPLY=1
fi

YES_PCT=$(echo "scale=4; $YES / $SUPPLY * 100" | bc)
NO_PCT=$(echo "scale=4; $NO / $SUPPLY * 100" | bc)
ABSTAIN_PCT=$(echo "scale=4; $ABSTAIN / $SUPPLY * 100" | bc)
TOTAL_PCT=$(echo "scale=4; $TOTAL / $SUPPLY * 100" | bc)

# Check if YES + NO is zero to avoid division by zero
if [[ "$YES" -eq 0 && "$NO" -eq 0 ]]; then
    YES_RATE=0
    NO_RATE=0
else
    YES_RATE=$(echo "scale=4; ($YES * 100) / ($YES + $NO)" | bc)
    NO_RATE=$(echo "scale=4; ($NO * 100) / ($YES + $NO)" | bc)
fi

print_row "YES" "$YES_PCT" "$YES"
print_row "NO" "$NO_PCT" "$NO"
print_row "ABSTAIN" "$ABSTAIN_PCT" "$ABSTAIN"
echo ""
print_row "YES RATE" "$YES_RATE" 0
print_row "NO RATE" "$NO_RATE" 0
echo ""
print_row "CAST" "$TOTAL_PCT" "$TOTAL"
print_row "SUPPLY" "100.0000" "$SUPPLY"
