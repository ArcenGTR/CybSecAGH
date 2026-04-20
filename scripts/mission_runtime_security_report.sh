#!/bin/bash

shopt -s extglob

mkdir -p ../reports
report_file="../reports/mission_runtime_security_report_$(date +%Y-%m-%d_%H-%M-%S).txt"

cpu_threshold=50
err_threshold=10

declare -A proc_whitelist=(
    ["gnome-shell"]=1
    ["bash"]=1
    ["sleep"]=1
    ["grep"]=1
    ["ps"]=1
    ["systemd"]=1
    ["awk"]=1
    ["tail"]=1
    ["read"]=1
)

total_processed_logs=$(ls ../logs/!(*-backup).log 2>/dev/null | wc -l)
total_active_processes=$(ps -eo pid --no-headers | wc -l)

unauthorized_count=0
high_cpu_count=0

while read -r cpu pid comm; do
    if [[ -z "$cpu" || "$cpu" == "%CPU" ]]; then continue; fi

    if [[ -z "${proc_whitelist[$comm]}" ]]; then
        ((unauthorized_count++))
    fi

    if (( $(echo "$cpu >= $cpu_threshold" | bc -l) )); then
        ((high_cpu_count++))
    fi
done < <(ps -eo %cpu,pid,comm --no-headers)

top_cpu_exists="no"
if [ "$high_cpu_count" -gt 0 ]; then
    top_cpu_exists="yes"
fi

total_errors=0
most_unstable_log=""
max_errs=0
suspicious_logs=0

for file in ../logs/!(*-backup).log; do
    [[ -e "$file" ]] || continue
    err_count=$(grep -c "ERROR" "$file")
    total_errors=$((total_errors + err_count))
    
    if [ "$err_count" -gt "$max_errs" ]; then
        max_errs=$err_count
        most_unstable_log=$(basename "$file")
    fi
    
    if (( $(echo "$err_count >= $err_threshold" | bc -l) )); then
        suspicious_logs=1
    fi
done

suspicious_cpu=0
[ "$high_cpu_count" -gt 0 ] && suspicious_cpu=1

suspicious_proc=0
[ "$unauthorized_count" -gt 0 ] && suspicious_proc=1

total_indicators=$((suspicious_cpu + suspicious_proc + suspicious_logs))

if [ "$total_indicators" -eq 0 ]; then
    classification="NORMAL"
elif [ "$total_indicators" -eq 1 ]; then
    classification="WARNING"
else
    classification="CRITICAL"
fi

{
    echo "MISSION RUNTIME SECURITY REPORT"
    echo "Generated at: $(date '+%Y-%m-%d_%H-%M-%S')"
    echo "Processed log files: $total_processed_logs"
    echo "Active processes: $total_active_processes"
    echo "Unauthorized processes: $unauthorized_count"
    echo "High CPU processes: $high_cpu_count"
    echo "ERROR entries: $total_errors"
    echo "Most unstable log: $most_unstable_log"
    echo "Top CPU process: $top_cpu_exists"
    echo "Incident classification: $classification"
} | tee "$report_file"

shopt -u extglob