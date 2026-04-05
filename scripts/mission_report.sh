#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <pattern>"
    exit 1
fi

pattern="$1"

# Expanding the pattern to file array
shopt -s nullglob
files=($pattern)
shopt -u nullglob

if [[ ${#files[@]} -eq 0 ]]; then
    echo "Error: Pattern '$pattern' matched no files or is invalid."
    exit 1
fi

shopt -s extglob

declare -A sat_error_map
report_file="../reports/mission_report.txt"
num_files_processed=${#files[@]}
num_log_entries=0
num_err_count=0
num_info_count=0
num_warn_count=0

> $report_file

for file in ${files[@]}
do 
    (( num_err_count += $(grep -cw "ERROR" "$file") ))
    (( num_info_count += $(grep -cw "INFO" "$file") ))
    (( num_warn_count += $(grep -cw "WARN" "$file") ))
    
    num_log_entries=$(($num_log_entries + $(wc -l < "$file")))
done

# Sorting and printing the results
echo "MISSION REPORT" >> $report_file
echo "Processed files: $num_files_processed" >> $report_file
echo "Total entries: $num_log_entries" >> $report_file
echo "ERROR: $num_err_count" >> $report_file
echo "INFO: $num_info_count" >> $report_file
echo "WARN: $num_warn_count" >> $report_file
echo "Most unstable log: $(./detect_noisiest_satellite.sh | head -n 1)" >> $report_file
shopt -u extglob


