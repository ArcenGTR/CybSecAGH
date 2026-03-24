#!/bin/bash

FILE1="../logs/sat-001.log"
FILE2="../logs/sat-002.log"

COUNT1=$(grep "ERROR" "$FILE1" | wc -l)
COUNT2=$(grep "ERROR" "$FILE2" | wc -l)

echo "Sat 1 ERROR count: $COUNT1"
echo "Sat 2 ERROR count: $COUNT2"

