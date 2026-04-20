#!/bin/bash

shopt -s extglob

report_file="../reports/runtime_monitor_$(date +%Y%m%d_%H%M%S).txt"

echo "Starting monitoring loop..."
echo "Interval: 5s"
echo "Output: $report_file"
echo "Using: ./incident_classifier.sh"
echo "Press Ctrl+C to stop."
echo "----------------------------------------"
echo "===== Monitoring started: $(date '+%Y-%m-%d %H:%M:%S') =====" | tee -a "$report_file"

cpu_threshold=50
err_threshold=10

declare -A proc_whitelist=(
    ["gnome-shell"]=1
    ["bash"]=1
    ["sleep"]=1
    ["grep"]=1
    ["ps"]=1
    ["systemd"]=1
)

while true; do
    ts=$(date '+%Y-%m-%d %H:%M:%S')
    
    read -r pid cpu comm <<< $(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 2 | tail -n 1)
    
    if (( $(echo "$cpu >= $cpu_threshold" | bc -l) )); then
        cpu_str="yes (PID=$pid, CPU=$cpu%)"
        suspicious_cpu=1
    else
        cpu_str="no"
        suspicious_cpu=0
    fi

    unauth_count=0
    while read -r comm; do
        if [[ -z "${proc_whitelist[$comm]}" ]]; then
            ((unauth_count++))
        fi
    done < <(ps -eo comm | tail -n +2)

    if [ "$unauth_count" -gt 0 ]; then
        suspicious_proc=1
    else
        suspicious_proc=0
    fi

    log_anomaly=0
    for file in ../logs/!(*-backup).log; do
        [[ -e "$file" ]] || continue
        err_count=$(grep -c "ERROR" "$file")
        if (( $(echo "$err_count >= $err_threshold" | bc -l) )); then
            log_anomaly=1
            break
        fi
    done

    if [ $log_anomaly -eq 1 ]; then
        log_str="YES"
    else
        log_str="NO"
    fi

    total=$((suspicious_cpu + suspicious_proc + log_anomaly))
    
    if [ $total -eq 0 ]; then
        status="NORMAL"
    elif [ $total -eq 1 ]; then
        status="WARNING"
    else
        status="CRITICAL"
    fi

    echo "[$ts] TOP_CPU: $cpu_str | UNAUTHORIZED: $unauth_count | LOG_ANOMALY: $log_str | STATUS: $status" | tee -a "$report_file"

    sleep 5
done