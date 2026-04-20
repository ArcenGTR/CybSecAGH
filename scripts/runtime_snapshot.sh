#!/bin/bash

shopt -s extglob

mkdir -p ../reports
snap_file="../reports/runtime_snapshot_$(date +%Y-%m-%d_%H-%M-%S).txt"

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

total_processes=$(ps -eo pid | tail -n +2 | wc -l)

read -r top_cpu top_pid top_comm <<< $(ps -eo %cpu,pid,comm --sort=-%cpu | head -n 2 | tail -n 1)

suspicious_cpu=0
if (( $(echo "$top_cpu >= $cpu_threshold" | bc -l) )); then
    suspicious_cpu=1
fi

unauthorized_list=""
unauthorized_count=0
while read -r pid comm; do
    if [[ -z "${proc_whitelist[$comm]}" ]]; then
        unauthorized_list+="- PID=$pid PROC=$comm"$'\n'
        ((unauthorized_count++))
    fi
done < <(ps -eo pid,comm | tail -n +2)

suspicious_proc=0
if [ "$unauthorized_count" -gt 0 ]; then
    suspicious_proc=1
fi

total_errors=0
log_summary=""
max_err=0
most_unstable=""
suspicious_logs=0

for file in ../logs/!(*-backup).log; do
    [[ -e "$file" ]] || continue
    err_count=$(grep -c "ERROR" "$file")
    log_summary+="- $(basename "$file"): $err_count ERROR entries"$'\n'
    total_errors=$((total_errors + err_count))
    if (( $(echo "$err_count >= $err_threshold" | bc -l) )); then
        suspicious_logs=1
    fi
    if [ "$err_count" -gt "$max_err" ]; then
        max_err=$err_count
        most_unstable="$(basename "$file")"
    fi
done

total_indicators=$((suspicious_cpu + suspicious_proc + suspicious_logs))

status="NORMAL"
summary="no suspicious indicators were observed"
if [ "$total_indicators" -eq 1 ]; then
    status="WARNING"
    summary="exactly one suspicious indicator was observed"
elif [ "$total_indicators" -ge 2 ]; then
    status="CRITICAL"
    summary="at least two suspicious indicators were observed simultaneously"
fi

{
    echo "========================================"
    echo "Runtime Security Snapshot"
    echo "========================================"
    echo "Date and time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Total active processes: $total_processes"
    echo "Top CPU process: PID=$top_pid PROC=$top_comm CPU=$top_cpu%"
    echo "Unauthorized processes: $unauthorized_count"
    echo "Total ERROR entries across all logs: $total_errors"
    echo "Incident classification: $status"
    echo "Classification summary: $summary"
    echo "----------------------------------------"
    echo "Thresholds:"
    echo "- CPU threshold: $cpu_threshold%"
    echo "- ERROR threshold per log: $err_threshold"
    echo "----------------------------------------"
    echo "Triggered indicators:"
    if [ "$suspicious_cpu" -eq 1 ]; then
        echo "- high CPU: top process $top_comm (PID=$top_pid) uses $top_cpu% > threshold $cpu_threshold%"
    fi
    if [ "$suspicious_proc" -eq 1 ]; then
        echo "- unauthorized processes detected: $unauthorized_count"
    fi
    if [ "$suspicious_logs" -eq 1 ]; then
        echo "- log anomaly: at least one mission log exceeds ERROR threshold $err_threshold"
    fi
    echo "----------------------------------------"
    echo "Log summary:"
    echo -n "$log_summary"
    echo "Most unstable log: $most_unstable ($max_err ERROR entries)"
    echo "----------------------------------------"
    echo "Unauthorized process details:"
    if [ -n "$unauthorized_list" ]; then
        echo -n "$unauthorized_list"
    fi
} | tee "$snap_file"

shopt -u extglob