#!/bin/bash

shopt -s extglob

declare -a clean_logs

for file in ../logs/!(*-backup).log
do 
    if ! grep -q "ERROR" "$file"; then
        clean_logs+=("$file")
    fi
done

if [[ ${#clean_logs[@]} -eq 0 ]]; then
    echo "No clean logs found."
    exit 0
else
    printf "%s\n" "${clean_logs[@]}" | sort
fi 

shopt -u extglob