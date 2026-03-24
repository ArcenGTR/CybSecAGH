#!/bin/bash

LOG_FILE=" ../reports/warn_timestamps.txt"
FILE1="../logs/sat-001.log"
FILE2="../logs/sat-002.log"

> $LOG_FILE

grep "WARN" "$FILE1" | awk '{ printf "%s %s\n", $1, $2 }' | sed "s/^/[SAT1] /" >> $LOG_FILE
grep "WARN" "$FILE2" | awk '{ printf "%s %s\n", $1, $2 }' | sed "s/^/[SAT2] /" >> $LOG_FILE


