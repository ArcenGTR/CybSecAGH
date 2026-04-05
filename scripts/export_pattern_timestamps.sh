#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <pattern>"
    exit 1
fi

shopt -s extglob

declare -A sat_error_map
report_file="../reports/pattern_timestamps.txt"

> $report_file

for file in ../logs/!(*-backup).log
do 
    # -c for count, -w for whole word match
    err_count=$(grep -cw "$1" "$file")
    sat_error_map["$file"]=$err_count
done

# Sorting and printing the results
echo "PATTERN TIMESTAMPS: $1" >> $report_file
for file in ${!sat_error_map[@]}
do
	echo "$(awk '{ printf "%s %s\n", $1, $2 }' "$file" | sed "s/^/[$(basename "$file" .log)] /")"
done | sort -k2,2r -k3,3r >> $report_file

shopt -u extglob


