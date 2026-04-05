#!/bin/bash

shopt -s extglob

declare -A sat_error_map

num_err_count=0
num_info_count=0
num_warn_count=0

for file in ../logs/!(*-backup).log
do 
    (( num_err_count += $(grep -cw "ERROR" "$file") ))
    (( num_info_count += $(grep -cw "INFO" "$file") ))
    (( num_warn_count += $(grep -cw "WARN" "$file") ))
done

echo "ERROR: $num_err_count"
echo "INFO: $num_info_count"
echo "WARN: $num_warn_count"
 
shopt -u extglob


