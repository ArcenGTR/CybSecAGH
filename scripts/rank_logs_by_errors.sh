#!/bin/bash

shopt -s extglob

declare -A sat_error_map

for file in ../logs/!(*-backup).log
do 
    err_count=$(grep -c "ERROR" "$file")
    sat_error_map["$file"]=$err_count
done

for file in ${!sat_error_map[@]}
do
	echo "$(basename "$file" .log) ${sat_error_map[$file]}"
done | sort -k2,2nr

shopt -u extglob


