#!/bin/bash

FILE1="../logs/sat-001.log"

COUNT1=$(grep "ERROR" "$FILE1" | wc -l)
COUNT2=$(grep "WARN" "$FILE1" | wc -l)
COUNT3=$(grep "INFO" "$FILE1" | wc -l)

echo "Sat 1 ERROR count: $COUNT1"
echo "Sat 1 WARN count: $COUNT2"
echo "Sat 1 INFO count: $COUNT3"

