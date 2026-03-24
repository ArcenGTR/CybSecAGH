#!/bin/bash

LOG_FILE=" ../reports/all_errors.txt"
FILE1="../logs/sat-001.log"
FILE2="../logs/sat-002.log"

> $LOG_FILE

grep "ERROR" "$FILE1" | sed "s/^/[SAT1] /" >> $LOG_FILE
grep "ERROR" "$FILE2" | sed "s/^/[SAT2] /" >> $LOG_FILE


