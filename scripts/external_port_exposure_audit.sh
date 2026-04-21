#!/bin/bash

TARGET_IP="127.0.0.1"
EXPECTED_PORTS=(631 5000 6000)

total_unexpected=0

DETECTED_PORTS=$(nmap -sT -n -Pn $TARGET_IP | grep "/tcp open" | cut -d'/' -f1)

for port in $DETECTED_PORTS; do
    is_expected=false
    for allowed in "${EXPECTED_PORTS[@]}"; do
        if [ "$port" == "$allowed" ]; then
            is_expected=true
            break
        fi
    done

    if [ "$is_expected" = false ]; then
        (( total_unexpected++ ))
        echo "EXPOSED PORT: $port"
    fi 
done

if [ $total_unexpected -eq 0 ]; then
    echo "NO UNEXPECTED EXPOSED PORTS"
fi


