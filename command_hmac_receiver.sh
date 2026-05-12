#!/bin/bash

PORT=6003
REPORT_DIR="./reports"
LOG_FILE="$REPORT_DIR/command_hmac_authentication.log"

mkdir -p "$REPORT_DIR"
touch "$LOG_FILE"

echo "=== AUTHORIZED COMMAND RECEIVER STARTED ==="
echo "Listening on 127.0.0.1:$PORT"
echo "Logging to $LOG_FILE"
echo ""

while true; do
    nc -l 127.0.0.1 "$PORT" | while IFS= read -r line; do
        TS=$(date -Iseconds)

        USER_NAME=$(echo "$line" | grep -o 'USER=[^;]*' | cut -d= -f2)
        ROLE=$(echo "$line" | grep -o 'ROLE=[^;]*' | cut -d= -f2)
        CMD=$(echo "$line" | grep -o 'CMD=[^;]*' | cut -d= -f2)
        MSG_TS=$(echo "$line" | grep -o 'TIMESTAMP=[^;]*' | cut -d= -f2)
        RECEIVED_AUTH=$(echo "$line" | grep -o 'AUTH=[^;]*' | cut -d= -f2)

        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD"
        echo "[RECEIVED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD MSG_TS=$MSG_TS RAW=$line" >> "$LOG_FILE"

        AUTHORIZED="no"

        USER_DB="./credentials/user_db.txt"
        ENTRY=$(grep "^$USER_NAME:" "$USER_DB")

        if [ -z "$ENTRY" ]; then
            echo "[REJECTED] UNKNOWN USER: $USER_NAME"
            echo "[REJECTED] UNKNOWN USER: $USER_NAME RAW=$line" >> "$LOG_FILE"
            continue
        fi

        DB_ROLE=$(echo "$ENTRY" | cut -d: -f2)
        DB_TOKEN=$(echo "$ENTRY" | cut -d: -f3)

        if [ "$ROLE" != "$DB_ROLE" ] || [ "$TOKEN" != "$DB_TOKEN" ]; then
            echo "[REJECTED] AUTHENTICATION FAILED: $USER_NAME"
            echo "[REJECTED] AUTHENTICATION FAILED: $USER_NAME RAW=$line" >> "$LOG_FILE"
            continue
        fi

        DATA="USER=$USER;ROLE=$ROLE;CMD=$CMD;TIMESTAMP=$TIMESTAMP"
        EXPECTED_AUTH=$(printf "%s" "$DATA" | openssl dgst -sha256 -hmac "$DB_TOKEN" | cut -d'' -f2)

        if [ "$RECEIVED_AUTH" != "$EXPECTED_AUTH" ]; then
            echo "[REJECTED] INVALID AUTH: $USER"
            echo "[REJECTED] INVALID AUTH: $USER RAW=$line" >> "$LOG_FILE"
            continue
        fi

        if [ "$ROLE" = "admin" ]; then
            case "$CMD" in
                SET_MODE_NOMINAL|SET_MODE_SAFE|RESET|SHUTDOWN)
                    AUTHORIZED="yes"
                    ;;
            esac
        elif [ "$ROLE" = "operator" ]; then
            case "$CMD" in
                SET_MODE_NOMINAL|SET_MODE_SAFE)
                    AUTHORIZED="yes"
                    ;;
            esac
        fi

        if [ "$AUTHORIZED" != "yes" ]; then
            echo "[REJECTED $TS] UNAUTHORIZED USER=$USER_NAME ROLE=$ROLE CMD=$CMD"
            echo "[REJECTED $TS] UNAUTHORIZED USER=$USER_NAME ROLE=$ROLE CMD=$CMD RAW=$line" >> "$LOG_FILE"
            echo ""
            continue
        fi

        echo "[AUTHORIZED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD"
        echo "[AUTHORIZED $TS] USER=$USER_NAME ROLE=$ROLE CMD=$CMD RAW=$line" >> "$LOG_FILE"

        case "$CMD" in
            SET_MODE_NOMINAL)
                echo "[ACTION] Switching satellite mode to NOMINAL"
                echo "[ACTION $TS] SET_MODE_NOMINAL" >> "$LOG_FILE"
                ;;
            SET_MODE_SAFE)
                echo "[ACTION] Switching satellite mode to SAFE"
                echo "[ACTION $TS] SET_MODE_SAFE" >> "$LOG_FILE"
                ;;
            RESET)
                echo "[ACTION] Simulated satellite reset"
                echo "[ACTION $TS] RESET" >> "$LOG_FILE"
                ;;
            SHUTDOWN)
                echo "[ACTION] Simulated satellite shutdown"
                echo "[ACTION $TS] SHUTDOWN" >> "$LOG_FILE"
                ;;
            *)
                echo "[UNKNOWN COMMAND] $CMD"
                echo "[UNKNOWN $TS] RAW=$line" >> "$LOG_FILE"
                ;;
        esac

        echo ""
    done
done
