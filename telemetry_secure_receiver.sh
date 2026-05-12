#!/bin/bash

PORT=5001

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="$SCRIPT_DIR/reports"
LOG_FILE="$REPORT_DIR/telemetry_secure.log"
STATE_FILE="$REPORT_DIR/last_timestamp.db"

SECRET_KEY="orion-shared-secret"

mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"
touch "$STATE_FILE"

echo "=== SECURE TELEMETRY RECEIVER (HMAC-SHA256 + REPLAY PROTECTION) ==="
echo "Listening on port $PORT"
echo "Logging to $LOG_FILE"
echo "Verifying messages with HMAC-SHA256"
echo "Detecting replay attacks using timestamp validation"
echo ""

while true; do
    nc -l 127.0.0.1 "$PORT" | while IFS= read -r line; do
        TS=$(date -Iseconds)

        DATA=$(echo "$line" | sed 's/;SIGNATURE=.*//')

        RECEIVED_SIGNATURE=$(echo "$line" | sed 's/.*;SIGNATURE=//')
        
        EXPECTED_SIGNATURE=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$SECRET_KEY" | cut -d' ' -f2)
        
        if [ "$RECEIVED_SIGNATURE" != "$EXPECTED_SIGNATURE" ]; then
            echo "[REJECTED $TS] INVALID SIGNATURE: $line"
            echo "[REJECTED $TS] INVALID SIGNATURE: $line" >> "$LOG_FILE"
            continue
        fi
        
        # Extract timestamp and satellite ID for replay detection
        MESSAGE_TIMESTAMP=$(echo "$DATA" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        SAT_ID=$(echo "$DATA" | grep -o 'SAT_ID=[^;]*' | cut -d= -f2)
        
        # Check for replay attacks
        LAST_TS=$(grep "^$SAT_ID=" "$STATE_FILE" 2>/dev/null | cut -d= -f2)
        
        if [[ -n "$LAST_TS" ]] && [[ ! "$MESSAGE_TIMESTAMP" > "$LAST_TS" ]]; then
            echo "[REJECTED $TS] REPLAY DETECTED from $SAT_ID: $DATA"
            echo "[REJECTED $TS] REPLAY DETECTED from $SAT_ID: $DATA" >> "$LOG_FILE"
            continue
        fi
        
        # Message passed all checks - accept it
        echo "[ACCEPTED $TS] $DATA"
        echo "[ACCEPTED $TS] $DATA" >> "$LOG_FILE"
        
        # Update last known timestamp for this satellite
        TMP_FILE=$(mktemp)
        grep -v "^$SAT_ID=" "$STATE_FILE" > "$TMP_FILE" 2>/dev/null && mv "$TMP_FILE" "$STATE_FILE"
        echo "$SAT_ID=$MESSAGE_TIMESTAMP" >> "$STATE_FILE"
    done
done
