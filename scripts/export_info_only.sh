#!/bin/bash

LOG_FILE="../reports/info_only.txt"
> $LOG_FILE

cat ../*.log | while read -r line; do
    if [[ "$line" == *"INFO"* ]]; then
        echo "$line" >> $LOG_FILE
    fi
done
