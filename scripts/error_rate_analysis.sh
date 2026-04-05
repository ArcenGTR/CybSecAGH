#!/bin/bash

shopt -s extglob

declare -A msg_file_count
declare -A msg_seen_in_current_file

for file in ../logs/!(*-backup).log
do 
    unset msg_seen_in_current_file
    declare -A msg_seen_in_current_file

    while read -r line; do
        msg=$(echo "$line" | cut -d " " -f 3-)
        
        if [[ -z "${msg_seen_in_current_file[$msg]}" ]]; then
            (( msg_file_count["$msg"]++ ))
            msg_seen_in_current_file["$msg"]=1
        fi
    done < "$file"
done

for msg in "${!msg_file_count[@]}"
do
    if [[ ${msg_file_count["$msg"]} -gt 1 ]]; then
        echo "Found in ${msg_file_count["$msg"]} files: $msg"
    fi
done

shopt -u extglob