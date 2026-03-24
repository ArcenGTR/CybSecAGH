#!/bin/bash

LOG_FILE=" ../reports/level_summary.txt"
FILE1="../logs/sat-001.log"
FILE2="../logs/sat-002.log"

errors=0
warnings=0
infos=0

> $LOG_FILE

cat $FILE1 $FILE2 | while read -r line; do

	if [[ "$line" == *"ERROR"* ]]; then
		((errors++))
	elif [[ "$line" == *"WARN"* ]]; then
		((warnings++))
	elif [[ "$line" == *"INFO"* ]]; then
		((infos++))
	fi
	
echo "$errors $warnings $infos" > .count
done

read tot_err tot_warn tot_info < .count

echo "ERROR count: $tot_err" >> $LOG_FILE
echo "WARN count: $tot_warn" >> $LOG_FILE
echo "INFO count: $tot_info" >> $LOG_FILE


rm .count


