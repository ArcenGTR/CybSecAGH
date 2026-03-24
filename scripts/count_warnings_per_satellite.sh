#!/bin/bash

FILE1="../logs/sat-001.log"
FILE2="../logs/sat-002.log"

COUNT1=$(grep "WARN" "$FILE1" | wc -l)
COUNT2=$(grep "WARN" "$FILE2" | wc -l)

if [ "$COUNT1" -gt "$COUNT2" ]; then
	echo "Sat1 has the most WARNINGS: $COUNT1"
else
	echo "Sat2 has the most WARNINGS: $COUNT2"
fi

