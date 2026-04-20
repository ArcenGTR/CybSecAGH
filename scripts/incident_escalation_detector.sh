#!/bin/bash

shopt -s extglob

cpu_threshold=50
err_threshold=10

declare -A proc_whitelist
proc_whitelist=(
    ["gnome-shell"]=1
    ["bash"]=1
    ["sleep"]=1
    ["grep"]=1
    ["ps"]=1
    ["systemd"]=1
)

get_status_val() {
    local s_cpu=0
    local s_proc=0
    local s_logs=0

    # CPU check
    read -r cpu _ <<< $(ps -eo %cpu --sort=-%cpu | tail -n +2 | head -n 1)
    if (( $(echo "$cpu >= $cpu_threshold" | bc -l) )); then
        s_cpu=1
    fi

    # Unauthorized process check
    while read -r comm; do
        if [[ -z "${proc_whitelist[$comm]}" ]]; then
            s_proc=1
            break
        fi
    done < <(ps -eo comm | tail -n +2)

    # Log anomaly check
    for file in ../logs/!(*-backup).log; do
        [[ -e "$file" ]] || continue
        err_count=$(grep -c "ERROR" "$file")
        if (( $(echo "$err_count >= $err_threshold" | bc -l) )); then
            s_logs=1
            break
        fi
    done

    echo $((s_cpu + s_proc + s_logs))
}

status_to_name() {
    if [ "$1" -ge 2 ]; then
        echo "CRITICAL"
    elif [ "$1" -eq 1 ]; then
        echo "WARNING"
    else
        echo "NORMAL"
    fi
}

prev_val=$(get_status_val)

while true; do
    sleep 5
    curr_val=$(get_status_val)

    if [ "$curr_val" -gt "$prev_val" ]; then
        echo "ESCALATION DETECTED:"
        echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "From: $(status_to_name "$prev_val")"
        echo "To: $(status_to_name "$curr_val")"
        prev_val=$curr_val
    fi
done