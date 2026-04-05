#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <pattern>"
    exit 1
fi

shopt -s extglob

declare -A sat_error_map

for file in ../logs/!(*-backup).log
do 
    # -c for count, -w for whole word match
    err_count=$(grep -cw "$1" "$file")
    sat_error_map["$file"]=$err_count
done

# Sorting and printing the results
echo "PATTERN REPORT: $1"
for file in ${!sat_error_map[@]}
do
	echo "$(basename "$file" .log) ${sat_error_map[$file]}"
done | sort -k2,2nr

shopt -u extglob


