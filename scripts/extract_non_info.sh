#!/bin/bash

shopt -s extglob

total=0

for file in ../logs/!(*-backup).log
do 
    err_count=$(grep -c "ERROR" "$file")
    warn_count=$(grep -c "WARN" "$file")
    (( total += err_count + warn_count ))
done

echo "Total unstable logs: $total"

shopt -u extglob







