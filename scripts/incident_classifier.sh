#!/bin/bash

if [[ $# -ne 2 ]]; 
then
    echo "Usage: $0 <CPU_THRESHOLD> <ERROR_THRESHOLD>"
    exit 1
fi

cpu_threshold="$1"
err_threshold="$2"

suspicious_cpu=0
suspicious_proc=0
suspicious_logs=0

while read -r line;
do 
    set -- $line
    if (( $(echo "$1 >= $cpu_threshold" | bc -l) )); then
        suspicious_cpu=1
        break 
    fi
done < <(ps -eo %cpu,%mem,pid,comm | tail -n +2)

declare -A proc_whitelist
proc_whitelist=(
    ["gnome-shell"]=1
    ["bash"]=1
    ["sleep"]=1
    ["grep"]=1
    ["ps"]=1
    ["systemd"]=1
)

while read -r line;
do 
    set -- $line
    shift 2
    shift 1
    if [[ -z "${proc_whitelist[$1]}" ]]; then
        suspicious_proc=1
        break
    fi
done < <(ps -eo %cpu,%mem,pid,comm | tail -n +2)

shopt -s extglob
for file in ../logs/!(*-backup).log
do 
    [[ -e "$file" ]] || continue 
    err_count=$(grep -c "ERROR" "$file")
    if (( $(echo "$err_count >= $err_threshold" | bc -l) )); then
        suspicious_logs=1
        break
    fi
done
shopt -u extglob

total_indicators=$((suspicious_cpu + suspicious_proc + suspicious_logs))

if [[ $total_indicators -eq 0 ]]; then
    echo "NORMAL"
elif [[ $total_indicators -eq 1 ]]; then
    echo "WARNING"
else
    echo "CRITICAL"
fi