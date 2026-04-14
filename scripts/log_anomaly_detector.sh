#!/bin/bash

if [[ $# -ne 1 ]]; 
then
    echo "Error: Exactly one argument is required."
    echo "Usage: $0 <err_threshold>"
    exit 1
fi

err_threshold="$1"

shopt -s extglob

declare -A sat_error_map

for file in ../logs/!(*-backup).log
do 
    err_count=$(grep -c "ERROR" "$file")
    sat_error_map["$file"]=$err_count
done

for file in ${!sat_error_map[@]}
do
	echo "$(basename "$file"): ${sat_error_map[$file]} ERROR entries"
    if (( $(echo ""${sat_error_map[$file]}" >= $err_threshold" | bc -l) ));
    then
        echo "ALERT: log anomaly detected in $(basename "$file")"
    fi
done

echo ""
echo ""

echo "Most unstable log file:"
for file in ${!sat_error_map[@]}
do
	echo "$(basename "$file" .log) ${sat_error_map[$file]}"
done | sort -k2,2nr | head -n 1

shopt -u extglob


