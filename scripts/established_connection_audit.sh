#!/bin/bash

total_connections=0
connections=$(ss -tunp state established | tail -n +2)

if [ -z "$connections" ]; then
    echo "NO ESTABLISHED CONNECTIONS DETECTED"
else
    while read -r line; do
        local=$(echo "$line" | awk '{print $4}')
        remote=$(echo "$line" | awk '{print $5}')

        process_info=$(echo "$line" | grep -o 'users:.*' | sed 's/users:(("//g; s/"),pid=/,/g; s/,fd=[0-9]*))//g')
        process_name=$(echo "$process_info" | cut -d',' -f1)
        pid=$(echo "$process_info" | cut -d',' -f2)

        if [ -z "$pid" ]; then pid="unknown"; fi
        if [ -z "$process_name" ]; then process_name="unknown"; fi

        echo "ESTABLISHED CONNECTION: $local -> $remote $process_name $pid"
        (( total_connections++ ))
    done <<< "$connections"
fi

echo "TOTAL ESTABLISHED CONNECTIONS: $total_connections"