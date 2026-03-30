#!/bin/bash

LOG_DIR="../logs"
REPORT="../reports/log_summary.txt"
FILE1="$LOG_DIR/sat-001.log"
FILE2="$LOG_DIR/sat-002.log"

total=0
info_cnt=0
warn_cnt=0
err_cnt=0

cat $LOG_DIR/*.log | while read -r line; do
    ((total++))
    if [[ "$line" == *"INFO"* ]]; then
        ((info_cnt++))
    elif [[ "$line" == *"WARN"* ]]; then
        ((warn_cnt++))
    elif [[ "$line" == *"ERROR"* ]]; then
        ((err_cnt++))
    fi
    echo "$total $info_cnt $warn_cnt $err_cnt" > .stats_tmp
done

read tot_all tot_i tot_w tot_e < .stats_tmp

e1=$(grep -c "ERROR" "$FILE1")
e2=$(grep -c "ERROR" "$FILE2")

if [ "$e1" -ge "$e2" ]; then
    less_stable="sat-001"
else
    less_stable="sat-002"
fi

echo "ORION LOG SUMMARY" > $REPORT
echo "Total log entries: $tot_all" >> $REPORT
echo "INFO events: $tot_i" >> $REPORT
echo "WARN events: $tot_w" >> $REPORT
echo "ERROR events: $tot_e" >> $REPORT
echo "Less stable satellite: $less_stable" >> $REPORT

rm .stats_tmp

echo "Analiza zakończona. Raport zapisany w $REPORT"
